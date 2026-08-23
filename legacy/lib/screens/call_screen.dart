import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/gateway_service.dart';
import '../services/sip_service.dart';
import '../services/telephony_service.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final TextEditingController _numberController = TextEditingController();
  List<SipCall> _sipCalls = [];
  List<TelephonyCall> _telephonyCalls = [];
  List<CallRouting> _routings = [];

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    final sipService = context.read<SipService>();
    final telephonyService = context.read<TelephonyService>();
    final gatewayService = context.read<GatewayService>();

    sipService.callStateStream.listen((call) {
      setState(() {
        final index = _sipCalls.indexWhere((c) => c.id == call.id);
        if (index >= 0) {
          _sipCalls[index] = call;
        } else {
          _sipCalls.add(call);
        }
        // Remove ended calls after a delay
        if (call.state == SipCallState.ended) {
          Future.delayed(const Duration(seconds: 5), () {
            setState(() {
              _sipCalls.removeWhere((c) => c.id == call.id);
            });
          });
        }
      });
    });

    telephonyService.callStateStream.listen((call) {
      setState(() {
        final index = _telephonyCalls.indexWhere((c) => c.id == call.id);
        if (index >= 0) {
          _telephonyCalls[index] = call;
        } else {
          _telephonyCalls.add(call);
        }
        // Remove ended calls after a delay
        if (call.state == TelephonyCallState.ended) {
          Future.delayed(const Duration(seconds: 5), () {
            setState(() {
              _telephonyCalls.removeWhere((c) => c.id == call.id);
            });
          });
        }
      });
    });

    gatewayService.routingStream.listen((routing) {
      setState(() {
        final index = _routings.indexWhere((r) => r.id == routing.id);
        if (index >= 0) {
          _routings[index] = routing;
        } else {
          _routings.add(routing);
        }
        // Remove ended routings after a delay
        if (routing.state == CallRoutingState.ended) {
          Future.delayed(const Duration(seconds: 5), () {
            setState(() {
              _routings.removeWhere((r) => r.id == routing.id);
            });
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls'),
      ),
      body: Column(
        children: [
          // Dialer section
          _buildDialerSection(),
          
          // Quick dial section
          _buildQuickDialSection(),
          
          const Divider(),
          
          // Active calls and routings
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'SIP Calls'),
                      Tab(text: 'GSM Calls'),
                      Tab(text: 'Routings'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildSipCallsList(),
                        _buildTelephonyCallsList(),
                        _buildRoutingsList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialerSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Make Call',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+1234567890',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _makeCall,
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDialSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickButton(
                  'Test Call',
                  Icons.call_outlined,
                  () => _makeTestCall(),
                ),
                _buildQuickButton(
                  'Incoming',
                  Icons.call_received,
                  () => _simulateIncoming(),
                ),
                _buildQuickButton(
                  'End All',
                  Icons.call_end,
                  () => _endAllCalls(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(String label, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
          ),
          child: Icon(icon),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSipCallsList() {
    if (_sipCalls.isEmpty) {
      return const Center(
        child: Text('No active SIP calls'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sipCalls.length,
      itemBuilder: (context, index) {
        final call = _sipCalls[index];
        return _buildSipCallCard(call);
      },
    );
  }

  Widget _buildTelephonyCallsList() {
    if (_telephonyCalls.isEmpty) {
      return const Center(
        child: Text('No active GSM calls'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _telephonyCalls.length,
      itemBuilder: (context, index) {
        final call = _telephonyCalls[index];
        return _buildTelephonyCallCard(call);
      },
    );
  }

  Widget _buildRoutingsList() {
    if (_routings.isEmpty) {
      return const Center(
        child: Text('No active call routings'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _routings.length,
      itemBuilder: (context, index) {
        final routing = _routings[index];
        return _buildRoutingCard(routing);
      },
    );
  }

  Widget _buildSipCallCard(SipCall call) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCallStateColor(call.state),
          child: Icon(
            call.direction == SipCallDirection.incoming 
                ? Icons.call_received 
                : Icons.call_made,
            color: Colors.white,
          ),
        ),
        title: Text(call.remoteNumber),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('State: ${call.state.name}'),
            Text('Duration: ${_formatDuration(DateTime.now().difference(call.startTime))}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (call.state == SipCallState.ringing && call.direction == SipCallDirection.incoming)
              IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: () => _answerSipCall(call.id),
              ),
            if (call.state == SipCallState.active)
              IconButton(
                icon: const Icon(Icons.pause, color: Colors.orange),
                onPressed: () => _holdSipCall(call.id),
              ),
            if (call.state == SipCallState.hold)
              IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.blue),
                onPressed: () => _resumeSipCall(call.id),
              ),
            IconButton(
              icon: const Icon(Icons.call_end, color: Colors.red),
              onPressed: () => _endSipCall(call.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelephonyCallCard(TelephonyCall call) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTelephonyCallStateColor(call.state),
          child: Icon(
            call.direction == TelephonyCallDirection.incoming 
                ? Icons.call_received 
                : Icons.call_made,
            color: Colors.white,
          ),
        ),
        title: Text(call.number),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('State: ${call.state.name}'),
            Text('Duration: ${_formatDuration(DateTime.now().difference(call.startTime))}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (call.state == TelephonyCallState.ringing && call.direction == TelephonyCallDirection.incoming)
              IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: () => _answerTelephonyCall(),
              ),
            IconButton(
              icon: const Icon(Icons.call_end, color: Colors.red),
              onPressed: () => _endTelephonyCall(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutingCard(CallRouting routing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoutingStateColor(routing.state),
          child: Icon(
            routing.direction == CallRoutingDirection.sipToGsm 
                ? Icons.call_made 
                : Icons.call_received,
            color: Colors.white,
          ),
        ),
        title: Text(routing.number),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Direction: ${routing.direction.name}'),
            Text('State: ${routing.state.name}'),
            Text('Duration: ${_formatDuration(DateTime.now().difference(routing.startTime))}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.call_end, color: Colors.red),
          onPressed: () => _endRouting(routing.id),
        ),
      ),
    );
  }

  // Action methods
  Future<void> _makeCall() async {
    final number = _numberController.text.trim();
    if (number.isEmpty) return;

    final gatewayService = context.read<GatewayService>();
    await gatewayService.makeCallViaSip(number);
    _numberController.clear();
  }

  Future<void> _makeTestCall() async {
    _numberController.text = '+1234567890';
    await _makeCall();
  }

  Future<void> _simulateIncoming() async {
    final sipService = context.read<SipService>();
    sipService.simulateIncomingCall('+0987654321');
  }

  Future<void> _endAllCalls() async {
    final sipService = context.read<SipService>();
    final telephonyService = context.read<TelephonyService>();
    
    for (final call in _sipCalls) {
      await sipService.endCall(call.id);
    }
    
    await telephonyService.endCall();
  }

  Future<void> _answerSipCall(String callId) async {
    final sipService = context.read<SipService>();
    await sipService.answerCall(callId);
  }

  Future<void> _endSipCall(String callId) async {
    final sipService = context.read<SipService>();
    await sipService.endCall(callId);
  }

  Future<void> _holdSipCall(String callId) async {
    final sipService = context.read<SipService>();
    await sipService.holdCall(callId);
  }

  Future<void> _resumeSipCall(String callId) async {
    final sipService = context.read<SipService>();
    await sipService.resumeCall(callId);
  }

  Future<void> _answerTelephonyCall() async {
    final telephonyService = context.read<TelephonyService>();
    await telephonyService.answerCall();
  }

  Future<void> _endTelephonyCall() async {
    final telephonyService = context.read<TelephonyService>();
    await telephonyService.endCall();
  }

  Future<void> _endRouting(String routingId) async {
    // This would typically be handled by the gateway service
    // For now, we'll just simulate ending the routing
  }

  // Helper methods
  Color _getCallStateColor(SipCallState state) {
    switch (state) {
      case SipCallState.connecting:
        return Colors.orange;
      case SipCallState.ringing:
        return Colors.blue;
      case SipCallState.active:
        return Colors.green;
      case SipCallState.hold:
        return Colors.purple;
      case SipCallState.ended:
        return Colors.grey;
      case SipCallState.failed:
        return Colors.red;
    }
  }

  Color _getTelephonyCallStateColor(TelephonyCallState state) {
    switch (state) {
      case TelephonyCallState.idle:
        return Colors.grey;
      case TelephonyCallState.ringing:
        return Colors.blue;
      case TelephonyCallState.offhook:
        return Colors.orange;
      case TelephonyCallState.active:
        return Colors.green;
      case TelephonyCallState.hold:
        return Colors.purple;
      case TelephonyCallState.ended:
        return Colors.grey;
    }
  }

  Color _getRoutingStateColor(CallRoutingState state) {
    switch (state) {
      case CallRoutingState.connecting:
        return Colors.orange;
      case CallRoutingState.active:
        return Colors.green;
      case CallRoutingState.ended:
        return Colors.grey;
      case CallRoutingState.failed:
        return Colors.red;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
