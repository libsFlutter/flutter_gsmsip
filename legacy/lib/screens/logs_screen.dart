import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/gateway_service.dart';
import '../services/sip_service.dart';
import '../services/sms_service.dart';
import '../services/telephony_service.dart';
import '../services/clipboard_service.dart';
import '../utils/funny_messages.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final List<LogEntry> _logs = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  LogLevel _selectedLevel = LogLevel.all;
  bool _autoScroll = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupLogListeners();
  }

  void _setupLogListeners() {
    final gatewayService = context.read<GatewayService>();
    final sipService = context.read<SipService>();
    final smsService = context.read<SmsService>();
    final telephonyService = context.read<TelephonyService>();

    gatewayService.logStream.listen((log) => _addLog(log, LogLevel.info, 'Gateway'));
    sipService.logStream.listen((log) => _addLog(log, LogLevel.info, 'SIP'));
    smsService.logStream.listen((log) => _addLog(log, LogLevel.info, 'SMS'));
    telephonyService.logStream.listen((log) => _addLog(log, LogLevel.info, 'Telephony'));
  }

  void _addLog(String message, LogLevel level, String source) {
    // Добавляем забавные сообщения в зависимости от уровня лога
    String funnyMessage = message;
    if (level == LogLevel.error) {
      funnyMessage = '${FunnyMessages.getConnectionError()}\n$message';
    } else if (level == LogLevel.success) {
      funnyMessage = '${FunnyMessages.getSuccessMessage()}\n$message';
    }
    
    setState(() {
      _logs.insert(0, LogEntry(
        timestamp: DateTime.now(),
        level: level,
        source: source,
        message: funnyMessage,
      ));
      
      // Keep only last 1000 logs
      if (_logs.length > 1000) {
        _logs.removeRange(1000, _logs.length);
      }
    });

    // Auto scroll to top if enabled
    if (_autoScroll && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _getFilteredLogs();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Логи 📝'),
        actions: [
          IconButton(
            icon: Icon(_autoScroll ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_down_outlined),
            onPressed: () {
              setState(() {
                _autoScroll = !_autoScroll;
              });
            },
            tooltip: 'Автопрокрутка (следим за логами 👀)',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter logs',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearAllLogs,
            tooltip: 'Clear all logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search logs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Stats bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${filteredLogs.length} of ${_logs.length} logs',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (_selectedLevel != LogLevel.all)
                  Chip(
                    label: Text(_selectedLevel.name.toUpperCase(),
                        style: const TextStyle(fontSize: 10, color: Colors.white)),
                    backgroundColor: _getLevelColor(_selectedLevel),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      setState(() {
                        _selectedLevel = LogLevel.all;
                      });
                    },
                  ),
              ],
            ),
          ),

          // Logs list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: filteredLogs.length,
              itemBuilder: (context, index) {
                final log = filteredLogs[index];
                return _buildLogCard(log);
              },
            ),
          ),

          // Scroll FABs
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'scrollTop',
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  child: const Icon(Icons.keyboard_arrow_up),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'scrollBottom',
                  onPressed: () {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<LogEntry> _getFilteredLogs() {
    return _logs.where((log) {
      // Filter by level
      if (_selectedLevel != LogLevel.all && log.level != _selectedLevel) {
        return false;
      }
      // Filter by search query
      if (_searchQuery.isNotEmpty &&
          !log.message.toLowerCase().contains(_searchQuery) &&
          !log.source.toLowerCase().contains(_searchQuery)) {
        return false;
      }
      return true;
    }).toList();
  }

  Widget _buildLogCard(LogEntry log) {
    final levelColor = _getLevelColor(log.level);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: levelColor.withOpacity(0.3), width: 4),
      ),
      child: InkWell(
        onTap: () => _showLogDetails(log),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      log.level.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: levelColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Source badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      log.source,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Timestamp
                  Text(
                    _formatTime(log.timestamp),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Message
              Text(
                log.message,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return const Color(0xFF9CA3AF);
      case LogLevel.info:
        return const Color(0xFF3B82F6);
      case LogLevel.warning:
        return const Color(0xFFF59E0B);
      case LogLevel.error:
        return const Color(0xFFEF4444);
      case LogLevel.success:
        return const Color(0xFF10B981);
      case LogLevel.all:
        return Colors.grey;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Logs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LogLevel.values.where((l) => l != LogLevel.all).map((level) {
            return RadioListTile<LogLevel>(
              title: Text(level.name.toUpperCase()),
              value: level,
              groupValue: _selectedLevel,
              onChanged: (value) {
                setState(() {
                  _selectedLevel = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedLevel = LogLevel.all;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear Filter'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogDetails(LogEntry log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${log.level.name.toUpperCase()} - ${log.source}'),
        content: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(
            log.message,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ClipboardService.copy(log.message);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Log copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearAllLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Logs'),
        content: const Text('Are you sure you want to clear all logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _logs.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearLogs,
            tooltip: 'Очистить логи (убрать мусор 🗑️)',
          ),
          PopupMenuButton<LogLevel>(
            icon: const Icon(Icons.filter_list),
            initialValue: _selectedLevel,
            onSelected: (level) {
              setState(() {
                _selectedLevel = level;
              });
            },
            itemBuilder: (context) => LogLevel.values.map((level) {
              return PopupMenuItem(
                value: level,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getLevelColor(level),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(level.name.toUpperCase()),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search logs...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Stats bar
          _buildStatsBar(),
          
          // Logs list
          Expanded(
            child: _buildLogsList(),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'top',
            onPressed: _scrollToTop,
            child: const Icon(Icons.keyboard_arrow_up),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'bottom',
            onPressed: _scrollToBottom,
            child: const Icon(Icons.keyboard_arrow_down),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final filteredLogs = _getFilteredLogs();
    final totalLogs = _logs.length;
    final filteredCount = filteredLogs.length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Row(
        children: [
          Text(
            'Showing $filteredCount of $totalLogs logs',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          if (_selectedLevel != LogLevel.all)
            Chip(
              label: Text(
                _selectedLevel.name.toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: _getLevelColor(_selectedLevel).withOpacity(0.2),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _selectedLevel = LogLevel.all;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    final filteredLogs = _getFilteredLogs();
    
    if (filteredLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _logs.isEmpty 
                ? 'Пока тихо... Логи спят 😴' 
                : 'Ничего не найдено... Логи играют в прятки 🙈',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            if (_logs.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedLevel = LogLevel.all;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: filteredLogs.length,
      itemBuilder: (context, index) {
        final log = filteredLogs[index];
        return _buildLogCard(log);
      },
    );
  }

  Widget _buildLogCard(LogEntry log) {
    final levelColor = _getLevelColor(log.level);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      elevation: 1,
      child: InkWell(
        onTap: () => _showLogDetails(log),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: levelColor,
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: levelColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.level.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: levelColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.source,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(log.timestamp),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  log.message,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogDetails(LogEntry log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getLevelColor(log.level),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text('${log.source} Log'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Time: ${_formatDateTime(log.timestamp)}'),
              Text('Level: ${log.level.name.toUpperCase()}'),
              const SizedBox(height: 16),
              const Text('Message:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SelectableText(log.message),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                final clipboardService = ClipboardService();
                final logText = 'Time: ${_formatDateTime(log.timestamp)}\n'
                    'Level: ${log.level.name.toUpperCase()}\n'
                    'Message: ${log.message}';
                await clipboardService.copyToClipboard(logText);
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Log copied to clipboard')),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to copy: $e')),
                  );
                }
              }
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  List<LogEntry> _getFilteredLogs() {
    return _logs.where((log) {
      // Filter by level
      if (_selectedLevel != LogLevel.all && log.level != _selectedLevel) {
        return false;
      }
      
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final searchText = '${log.source} ${log.message}'.toLowerCase();
        if (!searchText.contains(_searchQuery)) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  void _clearLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Logs'),
        content: const Text('Are you sure you want to clear all logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _logs.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logs cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Color _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.all:
        return Colors.purple;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
  }
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String source;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.source,
    required this.message,
  });
}

enum LogLevel {
  all,
  debug,
  info,
  warning,
  error,
}