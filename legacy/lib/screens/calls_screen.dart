import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gateway_provider.dart';
import '../models/active_call.dart';
import '../utils/text_styles.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  List<ActiveCall> _calls = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCalls();
  }

  Future<void> _loadCalls() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulate loading calls
      await Future.delayed(const Duration(milliseconds: 500));
      
      _calls = [
        ActiveCall(
          id: 'call1',
          direction: 'incoming',
          fromNumber: '+1234567890',
          toNumber: '+0987654321',
          startTime: DateTime.now().subtract(const Duration(minutes: 30)),
          duration: const Duration(minutes: 5, seconds: 30),
          status: 'completed',
          lineId: '1',
          isSipSpeakerEnabled: false,
          isGsmSpeakerEnabled: true,
          isSipMicrophoneEnabled: true,
          isGsmMicrophoneEnabled: false,
          isRecording: false,
          recordingPath: '',
          sipMos: 4.2,
          gsmMos: 4.0,
          sipJitter: 12.5,
          gsmJitter: 8.3,
          sipLatency: 42.1,
          gsmLatency: 35.7,
        ),
        ActiveCall(
          id: 'call2',
          direction: 'outgoing',
          fromNumber: '+0987654321',
          toNumber: '+1234567890',
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          duration: const Duration(minutes: 2, seconds: 15),
          status: 'completed',
          lineId: '2',
          isSipSpeakerEnabled: true,
          isGsmSpeakerEnabled: false,
          isSipMicrophoneEnabled: false,
          isGsmMicrophoneEnabled: true,
          isRecording: true,
          recordingPath: '/recordings/call2.wav',
          sipMos: 4.5,
          gsmMos: 4.2,
          sipJitter: 10.2,
          gsmJitter: 7.8,
          sipLatency: 38.5,
          gsmLatency: 32.1,
        ),
      ];
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Call History'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCalls,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _makeCall,
        backgroundColor: Colors.green,
        child: const Icon(Icons.call, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading calls',
              style: TextStyles.title.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyles.body.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCalls,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_calls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No recent calls',
              style: TextStyles.title.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Your call history will appear here',
              style: TextStyles.body.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _calls.length,
      itemBuilder: (context, index) {
        final call = _calls[index];
        return Card(
          color: const Color(0xFF1A1A1A),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCallDirectionColor(call.direction),
              child: Icon(
                call.direction == 'incoming' 
                  ? Icons.call_received 
                  : Icons.call_made,
                color: Colors.white,
              ),
            ),
            title: Text(
              call.fromNumber ?? 'Unknown',
              style: TextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCallStatusText(call.status),
                  style: TextStyles.caption.copyWith(color: Colors.grey),
                ),
                if (call.startTime != null)
                  Text(
                    _formatDateTime(call.startTime!),
                    style: TextStyles.caption.copyWith(color: Colors.grey),
                  ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleCallAction(value, call),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'call',
                  child: Row(
                    children: [
                      Icon(Icons.call),
                      SizedBox(width: 8),
                      Text('Call'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'sms',
                  child: Row(
                    children: [
                      Icon(Icons.sms),
                      SizedBox(width: 8),
                      Text('Send SMS'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(Icons.info),
                      SizedBox(width: 8),
                      Text('Call Info'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCallDirectionColor(String direction) {
    switch (direction) {
      case 'incoming':
        return Colors.green;
      case 'outgoing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getCallStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'missed':
        return 'Missed';
      case 'rejected':
        return 'Rejected';
      case 'connected':
        return 'Connected';
      default:
        return 'Unknown';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleCallAction(String action, ActiveCall call) {
    switch (action) {
      case 'call':
        _makeCallToNumber(call.fromNumber ?? '');
        break;
      case 'sms':
        _sendSmsToNumber(call.fromNumber ?? '');
        break;
      case 'info':
        _showCallInfo(call);
        break;
    }
  }

  void _makeCall() {
    // Show call dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make Call'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter phone number',
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _makeCallToNumber(number);
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _makeCallToNumber(String number) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final gatewayProvider = Provider.of<GatewayProvider>(context, listen: false);
      
      // Инициируем звонок через GatewayProvider
      final success = await gatewayProvider.makeCall(number);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Calling $number...')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to make call')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _sendSmsToNumber(String number) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final gatewayProvider = Provider.of<GatewayProvider>(context, listen: false);
      
      // Открываем экран SMS с предзаполненным номером
      await Navigator.pushNamed(
        context,
        '/sms',
        arguments: {'recipient': number},
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening SMS to $number...')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCallInfo(ActiveCall call) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${call.fromNumber}'),
            Text('To: ${call.toNumber}'),
            Text('Duration: ${call.duration.inMinutes}:${(call.duration.inSeconds % 60).toString().padLeft(2, '0')}'),
            Text('Status: ${call.status}'),
            Text('Line ID: ${call.lineId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Calls'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Incoming'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Outgoing'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Missed'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
} 