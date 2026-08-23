import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/gateway_service.dart';
import '../services/sms_service.dart';
import '../services/clipboard_service.dart';

class SmsScreen extends StatefulWidget {
  const SmsScreen({super.key});

  @override
  State<SmsScreen> createState() => _SmsScreenState();
}

class _SmsScreenState extends State<SmsScreen> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  List<SmsMessage> _messages = [];
  bool _useSmpp = false;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _loadMessages();
  }

  void _setupListeners() {
    final smsService = context.read<SmsService>();
    
    smsService.messageStream.listen((message) {
      setState(() {
        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index >= 0) {
          _messages[index] = message;
        } else {
          _messages.insert(0, message);
        }
      });
    });
  }

  void _loadMessages() {
    final smsService = context.read<SmsService>();
    setState(() {
      _messages = smsService.messages;
    });
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Clear Messages'),
                onTap: _clearMessages,
              ),
              PopupMenuItem(
                child: const Text('Send Test SMS'),
                onTap: _sendTestSms,
              ),
              PopupMenuItem(
                child: const Text('Simulate Incoming'),
                onTap: _simulateIncoming,
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Compose section
          _buildComposeSection(),
          
          const Divider(),
          
          // Statistics
          _buildStatistics(),
          
          const Divider(),
          
          // Messages list
          Expanded(
            child: _buildMessagesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildComposeSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send SMS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _recipientController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Recipient',
                hintText: '+1234567890',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _messageController,
              maxLines: 3,
              maxLength: 160,
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Type your message here...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.message),
                suffixText: '${_messageController.text.length}/160',
                suffixStyle: TextStyle(
                  color: _messageController.text.length > 160 ? Colors.red : Colors.grey,
                  fontSize: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild for character counter
              },
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Switch(
                  value: _useSmpp,
                  onChanged: (value) {
                    setState(() {
                      _useSmpp = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text('Use SMPP'),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _sendSms,
                  icon: const Icon(Icons.send),
                  label: const Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    final smsService = context.read<SmsService>();
    final stats = smsService.getMessageStats();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SMS Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', stats['total']?.toString() ?? '0'),
                _buildStatItem('Sent', stats['sent']?.toString() ?? '0'),
                _buildStatItem('Delivered', stats['delivered']?.toString() ?? '0'),
                _buildStatItem('Failed', stats['failed']?.toString() ?? '0'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sms_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No messages',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageCard(message);
      },
    );
  }

  Widget _buildMessageCard(SmsMessage message) {
    final isIncoming = message.type == SmsMessageType.incoming;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getMessageStatusColor(message.status),
          child: Icon(
            isIncoming ? Icons.call_received : Icons.call_made,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                isIncoming ? message.sender : message.recipient,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Chip(
              label: Text(
                message.status.name.toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: _getMessageStatusColor(message.status).withOpacity(0.2),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(message.timestamp),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Copy'),
              onTap: () => _copyMessage(message.content),
            ),
            PopupMenuItem(
              child: const Text('Reply'),
              onTap: () => _replyToMessage(message),
            ),
            PopupMenuItem(
              child: const Text('Delete'),
              onTap: () => _deleteMessage(message.id),
            ),
          ],
        ),
        onTap: () => _showMessageDetails(message),
      ),
    );
  }

  // Action methods
  Future<void> _sendSms() async {
    final recipient = _recipientController.text.trim();
    final content = _messageController.text.trim();
    
    if (recipient.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter recipient and message'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final gatewayService = context.read<GatewayService>();
    final messageId = await gatewayService.sendSms(recipient, content, useSmpp: _useSmpp);
    
    if (messageId != null) {
      _recipientController.clear();
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SMS sent')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send SMS'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendTestSms() async {
    _recipientController.text = '+1234567890';
    _messageController.text = 'Test message from GOSTsimbox Gateway';
    await _sendSms();
  }

  Future<void> _simulateIncoming() async {
    final smsService = context.read<SmsService>();
    smsService.simulateIncomingSms('+0987654321', 'Incoming test message');
  }

  void _clearMessages() {
    final smsService = context.read<SmsService>();
    smsService.clearMessages();
    setState(() {
      _messages.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Messages cleared')),
    );
  }

  void _copyMessage(String content) async {
    try {
      final clipboardService = ClipboardService();
      await clipboardService.copyToClipboard(content);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message copied to clipboard')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to copy: $e')),
        );
      }
    }
  }

  void _replyToMessage(SmsMessage message) {
    final sender = message.type == SmsMessageType.incoming 
        ? message.sender 
        : message.recipient;
    _recipientController.text = sender;
    // Focus on message field
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _deleteMessage(String messageId) {
    final smsService = context.read<SmsService>();
    final deleted = smsService.deleteMessage(messageId);
    
    if (deleted) {
      setState(() {
        _messages.removeWhere((m) => m.id == messageId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message deleted')),
      );
    }
  }

  void _showMessageDetails(SmsMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          message.type == SmsMessageType.incoming 
              ? 'From: ${message.sender}' 
              : 'To: ${message.recipient}',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Message:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message.content),
            const SizedBox(height: 16),
            Text('Status: ${message.status.name}'),
            Text('Time: ${_formatDateTime(message.timestamp)}'),
            Text('ID: ${message.id}'),
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

  // Helper methods
  Color _getMessageStatusColor(SmsMessageStatus status) {
    switch (status) {
      case SmsMessageStatus.pending:
        return Colors.orange;
      case SmsMessageStatus.sent:
        return Colors.blue;
      case SmsMessageStatus.delivered:
        return Colors.green;
      case SmsMessageStatus.failed:
        return Colors.red;
      case SmsMessageStatus.received:
        return Colors.purple;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}