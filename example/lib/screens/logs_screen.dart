import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gsmsip/flutter_gsmsip.dart';

/// Merges [GatewayService.logStream] and [SmsService.logStream] — two
/// distinct streams, there's no unified log stream in the library — into
/// one bounded in-memory buffer with a text-search filter. No log-level
/// filter: the library's log lines aren't leveled/tagged, so that
/// control would be fake.
class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  static const _maxEntries = 500;

  final _gateway = GatewayService();
  final _smsService = SmsService();
  StreamSubscription<String>? _gatewayLogSub;
  StreamSubscription<String>? _smsLogSub;
  final _entries = <String>[];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _gatewayLogSub = _gateway.logStream.listen(_addEntry);
    _smsLogSub = _smsService.logStream.listen(_addEntry);
  }

  void _addEntry(String line) {
    if (!mounted) return;
    setState(() {
      _entries.add(line);
      if (_entries.length > _maxEntries) _entries.removeAt(0);
    });
  }

  @override
  void dispose() {
    _gatewayLogSub?.cancel();
    _smsLogSub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? _entries
        : _entries.where((e) => e.toLowerCase().contains(query)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear',
            onPressed: () => setState(_entries.clear),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No log entries yet'))
                : ListView.builder(
                    reverse: true,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final entry = filtered[filtered.length - 1 - index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text(
                          entry,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
