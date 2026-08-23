/// Call Screen with animations and state transitions
/// Implements VDD visual specifications for call UI

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../providers/sip_provider.dart';
import '../../providers/gateway_provider.dart';
import '../../entities/sip_call.dart';
import '../../entities/call_routing.dart';

class CallScreen extends StatefulWidget {
  final String? initialNumber;
  final String? routingId;

  const CallScreen({
    super.key,
    this.initialNumber,
    this.routingId,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _numberController = TextEditingController();
  final PageController _actionsPageController = PageController();
  int _currentActionsPage = 0;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _infoOffsetAnimation;
  late Animation<double> _avatarOpacityAnimation;
  late Animation<double> _avatarOffsetAnimation;
  late Animation<double> _actionsOpacityAnimation;
  late Animation<double> _actionsOffsetAnimation;

  // Call state
  SipCall? _activeCall;
  CallRouting? _activeRouting;
  CallState _callState = CallState.initiated;
  bool _isMuted = false;
  bool _isSpeaker = false;
  bool _isOnHold = false;

  // Multi-call handling
  List<SipCall> _otherCalls = [];
  bool _showIncomingCallModal = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _setupAnimations();

    if (widget.initialNumber != null) {
      _numberController.text = widget.initialNumber!;
    }

    // Initialize with incoming call state if routing provided
    if (widget.routingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRouting(widget.routingId!);
      });
    }
  }

  void _setupAnimations() {
    _infoOffsetAnimation = Tween<double>(begin: 0, end: -50).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _avatarOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _avatarOffsetAnimation = Tween<double>(begin: 0, end: 50).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _actionsOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _actionsOffsetAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _loadRouting(String routingId) async {
    final gatewayProvider = context.read<GatewayProvider>();
    final routing = gatewayProvider.activeRoutings[routingId];
    if (routing != null) {
      setState(() {
        _activeRouting = routing;
        _callState = routing.state == CallRoutingState.active
            ? CallState.active
            : CallState.incoming;
      });
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (_callState == CallState.active || _callState == CallState.held) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _actionsPageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2a5743), // Teal green
              const Color(0xFF14456f), // Deep blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Multi-call info strip
              if (_otherCalls.isNotEmpty) _buildCallParallelInfo(),

              // Main call content
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        // Call info section
                        AnimatedBuilder(
                          animation: _infoOffsetAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _infoOffsetAnimation.value),
                              child: child,
                            );
                          },
                          child: _buildCallInfo(),
                        ),

                        // Avatar section
                        AnimatedBuilder(
                          animation: _avatarOpacityAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _avatarOpacityAnimation.value,
                              child: Transform.translate(
                                offset: Offset(0, _avatarOffsetAnimation.value),
                                child: child,
                              ),
                            );
                          },
                          child: _buildAvatar(),
                        ),

                        // Call state
                        AnimatedBuilder(
                          animation: _infoOffsetAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _infoOffsetAnimation.value),
                              child: child,
                            );
                          },
                          child: _buildCallState(),
                        ),

                        // Call actions (ViewPager)
                        AnimatedBuilder(
                          animation: _actionsOpacityAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _actionsOpacityAnimation.value,
                              child: Transform.translate(
                                offset: Offset(0, _actionsOffsetAnimation.value),
                                child: child,
                              ),
                            );
                          },
                          child: _buildCallActions(),
                        ),

                        const Spacer(),

                        // Call controls
                        _buildCallControls(),
                      ],
                    ),
                  ],
                ),
              ),

              // Incoming call modal overlay
              if (_showIncomingCallModal) _buildIncomingCallModal(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallParallelInfo() {
    return Container(
      height: 60,
      color: Colors.black26,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _otherCalls.length,
        itemBuilder: (context, index) {
          final call = _otherCalls[index];
          return Card(
            margin: const EdgeInsets.all(4),
            color: Colors.white.withOpacity(0.9),
            child: InkWell(
              onTap: () {
                // Switch to this call
                setState(() {
                  _activeCall = call;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.number,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: call.state == CallState.active
                                ? Colors.green
                                : Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          call.state == CallState.held ? 'On Hold' : 'Active',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCallInfo() {
    final callerName = _activeCall?.callerName ?? _activeRouting?.number ?? '';
    final callerNumber = _activeCall?.number ?? _activeRouting?.number ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (callerName.isNotEmpty)
            Text(
              callerName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (callerNumber.isNotEmpty && callerNumber != callerName)
            Text(
              callerNumber,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.height * 0.3,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.2),
        child: Icon(
          Icons.person,
          size: MediaQuery.of(context).size.height * 0.15,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildCallState() {
    String stateText;
    switch (_callState) {
      case CallState.initiated:
        stateText = 'Calling...';
        break;
      case CallState.incoming:
        stateText = 'Incoming...';
        break;
      case CallState.active:
        stateText = 'Connected';
        break;
      case CallState.held:
        stateText = 'On Hold';
        break;
      case CallState.terminated:
        stateText = 'Ended';
        break;
      case CallState.failed:
        stateText = 'Failed';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        stateText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCallActions() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPageIndicator(0),
              const SizedBox(width: 8),
              _buildPageIndicator(1),
            ],
          ),
          const SizedBox(height: 16),
          // ViewPager with actions
          Expanded(
            child: PageView(
              controller: _actionsPageController,
              onPageChanged: (page) {
                setState(() {
                  _currentActionsPage = page;
                });
              },
              children: [
                _buildActionsPage1(),
                _buildActionsPage2(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int page) {
    final isActive = _currentActionsPage == page;
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white54,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildActionsPage1() {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 0.8,
      children: [
        _buildActionItem(
          icon: _isMuted ? Icons.mic_off : Icons.mic,
          label: _isMuted ? 'Unmute' : 'Mute',
          isActive: _isMuted,
          onTap: _toggleMute,
        ),
        _buildActionItem(
          icon: _isSpeaker ? Icons.volume_up : Icons.phone_in_talk,
          label: _isSpeaker ? 'Speaker' : 'Earpiece',
          isActive: _isSpeaker,
          onTap: _toggleSpeaker,
        ),
        _buildActionItem(
          icon: _isOnHold ? Icons.play_arrow : Icons.pause,
          label: _isOnHold ? 'Resume' : 'Hold',
          isActive: _isOnHold,
          onTap: _toggleHold,
        ),
        _buildActionItem(
          icon: Icons.person_add,
          label: 'Add Call',
          onTap: _addCall,
        ),
        _buildActionItem(
          icon: Icons.swap_horiz,
          label: 'Transfer',
          onTap: _transferCall,
        ),
        _buildActionItem(
          icon: Icons.dialpad,
          label: 'DTMF',
          onTap: _showDtmfDialog,
        ),
      ],
    );
  }

  Widget _buildActionsPage2() {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 0.8,
      children: [
        _buildActionItem(
          icon: Icons.local_parking,
          label: 'Park',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Call park not implemented')),
            );
          },
        ),
        _buildActionItem(
          icon: Icons.merge,
          label: 'Merge',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Call merge not implemented')),
            );
          },
        ),
        _buildActionItem(
          icon: Icons.fiber_manual_record,
          label: 'Record',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Call recording not implemented')),
            );
          },
        ),
        _buildActionItem(
          icon: Icons.chat,
          label: 'Chat',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chat not implemented')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withOpacity(0.3)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Hangup button
          _buildControlButton(
            icon: Icons.call_end,
            color: Colors.red,
            label: 'End',
            onTap: _endCall,
          ),

          // Answer button (only for incoming)
          if (_callState == CallState.incoming)
            _buildControlButton(
              icon: Icons.call,
              color: Colors.green,
              label: 'Answer',
              onTap: _answerCall,
            ),

          // Redirect button (only for incoming)
          if (_callState == CallState.incoming)
            _buildControlButton(
              icon: Icons.forward,
              color: Colors.orange,
              label: 'Redirect',
              onTap: _redirectCall,
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required String label,
    VoidCallback? onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomingCallModal() {
    return Stack(
      children: [
        // Transparent background
        ModalBarrier(
          color: Colors.transparent,
          dismissible: false,
        ),
        // Modal content
        Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.call,
                    size: 64,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _activeCall?.number ?? _activeRouting?.number ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'is calling',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Decline button
                      _buildModalButton(
                        icon: Icons.call_end,
                        color: Colors.red,
                        label: 'Decline',
                        onTap: () {
                          setState(() {
                            _showIncomingCallModal = false;
                          });
                          _declineCall();
                        },
                      ),
                      const SizedBox(width: 16),
                      // Answer button
                      _buildModalButton(
                        icon: Icons.call,
                        color: Colors.green,
                        label: 'Answer',
                        onTap: () {
                          setState(() {
                            _showIncomingCallModal = false;
                          });
                          _answerCall();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModalButton({
    required IconData icon,
    required Color color,
    required String label,
    VoidCallback? onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // ==================== Actions ====================

  void _answerCall() async {
    final gatewayProvider = context.read<GatewayProvider>();
    final routingId = _activeRouting?.id;

    if (routingId != null) {
      final success = await gatewayProvider.answerCall(routingId);
      if (success) {
        setState(() {
          _callState = CallState.active;
        });
        _updateAnimation();
      }
    }
  }

  void _endCall() async {
    final gatewayProvider = context.read<GatewayProvider>();
    final routingId = _activeRouting?.id;

    if (routingId != null) {
      final success = await gatewayProvider.endRouting(routingId);
      if (success) {
        setState(() {
          _callState = CallState.terminated;
        });
        _updateAnimation();

        // Navigate back after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    }
  }

  void _declineCall() async {
    final gatewayProvider = context.read<GatewayProvider>();
    final routingId = _activeRouting?.id;

    if (routingId != null) {
      await gatewayProvider.endRouting(routingId);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _redirectCall() async {
    // Show redirect dialog
    final redirectNumber = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Redirect Call'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Destination Number',
              hintText: 'Enter number to redirect to',
            ),
            keyboardType: TextInputType.phone,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Redirect'),
            ),
          ],
        );
      },
    );

    if (redirectNumber != null && redirectNumber.isNotEmpty) {
      final gatewayProvider = context.read<GatewayProvider>();
      final routingId = _activeRouting?.id;

      if (routingId != null) {
        // Redirect would be implemented in gateway
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Redirecting to $redirectNumber...')),
        );
      }
    }
  }

  void _toggleMute() async {
    final gatewayProvider = context.read<GatewayProvider>();
    final routingId = _activeRouting?.id;

    if (routingId != null) {
      if (_isMuted) {
        await gatewayProvider.unmuteCall(routingId);
      } else {
        await gatewayProvider.muteCall(routingId);
      }
      setState(() {
        _isMuted = !_isMuted;
      });
    }
  }

  void _toggleSpeaker() async {
    final gatewayProvider = context.read<GatewayProvider>();
    final routingId = _activeRouting?.id;

    if (routingId != null) {
      if (_isSpeaker) {
        await gatewayProvider.useEarpiece(routingId);
      } else {
        await gatewayProvider.useSpeaker(routingId);
      }
      setState(() {
        _isSpeaker = !_isSpeaker;
      });
    }
  }

  void _toggleHold() async {
    final gatewayProvider = context.read<GatewayProvider>();
    final routingId = _activeRouting?.id;

    if (routingId != null) {
      if (_isOnHold) {
        await gatewayProvider.unholdCall(routingId);
      } else {
        await gatewayProvider.holdCall(routingId);
      }
      setState(() {
        _isOnHold = !_isOnHold;
        _callState = _isOnHold ? CallState.held : CallState.active;
      });
      _updateAnimation();
    }
  }

  void _addCall() async {
    // Show dialer to add another call
    final number = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _numberController.text);
        return AlertDialog(
          title: const Text('Add Call'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter number to call',
            ),
            keyboardType: TextInputType.phone,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Call'),
            ),
          ],
        );
      },
    );

    if (number != null && number.isNotEmpty) {
      final gatewayProvider = context.read<GatewayProvider>();
      final routingId = await gatewayProvider.makeCall(number);

      if (routingId != null) {
        setState(() {
          _otherCalls.add(SipCall(
            id: routingId,
            accountId: '',
            number: number,
            direction: CallDirection.outgoing,
            state: CallState.initiated,
          ));
        });
      }
    }
  }

  void _transferCall() async {
    // Show transfer dialog
    final transferNumber = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Transfer Call'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Transfer To',
              hintText: 'Enter destination number',
            ),
            keyboardType: TextInputType.phone,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Transfer'),
            ),
          ],
        );
      },
    );

    if (transferNumber != null && transferNumber.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transferring to $transferNumber...')),
      );
    }
  }

  void _showDtmfDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('DTMF'),
          content: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              '1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'
            ].map((digit) {
              return ElevatedButton(
                onPressed: () {
                  _sendDtmf(digit);
                  Navigator.pop(context);
                },
                child: Text(digit, style: const TextStyle(fontSize: 24)),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _sendDtmf(String digit) async {
    final gatewayProvider = context.read<GatewayProvider>();
    final routingId = _activeRouting?.id;

    if (routingId != null) {
      await gatewayProvider.sendDtmf(routingId, digit);
      HapticFeedback.lightImpact();
    }
  }
}
