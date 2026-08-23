import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/text_styles.dart';
import '../providers/gateway_provider.dart';
import '../services/smpp_logger.dart';

class SmppLogsScreen extends StatefulWidget {
  const SmppLogsScreen({Key? key}) : super(key: key);

  @override
  State<SmppLogsScreen> createState() => _SmppLogsScreenState();
}

class _SmppLogsScreenState extends State<SmppLogsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredLogs = [];
  String _searchQuery = '';
  SmppLogLevel _selectedLogLevel = SmppLogLevel.info;

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _searchController.addListener(_filterLogs);
  }

  void _loadLogs() {
    final logs = SmppLogger().getLogs();
    _filteredLogs = List.from(logs);
    setState(() {});
  }

  void _filterLogs() {
    final query = _searchController.text.toLowerCase();
    final logs = SmppLogger().getLogs();
    
    _filteredLogs = logs.where((log) {
      final matchesSearch = query.isEmpty || log.toLowerCase().contains(query);
      final matchesLevel = _selectedLogLevel == SmppLogLevel.info || 
          log.contains('[${_selectedLogLevel.name.toUpperCase()}]');
      return matchesSearch && matchesLevel;
    }).toList();
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildLogLevelFilter(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _buildLogsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'SMPP Logs',
          style: AppTextStyles.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1A1A),
                const Color(0xFF2A2A2A),
                const Color(0xFF1A1A1A),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.refresh, color: Colors.white, size: 20),
          ),
          onPressed: _loadLogs,
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.clear, color: Colors.white, size: 20),
          ),
          onPressed: _clearLogs,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.poppins(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search logs...',
          hintStyle: AppTextStyles.poppins(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: () {
                    _searchController.clear();
                    _filterLogs();
                  },
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[600]!),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildLogLevelFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Log Level: ',
            style: AppTextStyles.poppins(color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: SmppLogLevel.values.map((level) {
                  final isSelected = _selectedLogLevel == level;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        level.name.toUpperCase(),
                        style: AppTextStyles.poppins(
                          color: isSelected ? Colors.white : Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedLogLevel = level;
                        });
                        _filterLogs();
                      },
                      backgroundColor: Colors.grey[800],
                      selectedColor: _getLogLevelColor(level),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLogLevelColor(SmppLogLevel level) {
    switch (level) {
      case SmppLogLevel.debug:
        return Colors.blue;
      case SmppLogLevel.info:
        return Colors.green;
      case SmppLogLevel.warning:
        return Colors.orange;
      case SmppLogLevel.error:
        return Colors.red;
    }
  }

  Widget _buildLogsList() {
    if (_filteredLogs.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No logs found',
                  style: AppTextStyles.poppins(
                    color: Colors.grey[600],
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search or log level filter',
                  style: AppTextStyles.poppins(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount: _filteredLogs.length,
      itemBuilder: (context, index) {
        final log = _filteredLogs[index];
        final logLevel = _extractLogLevel(log);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getLogLevelColor(logLevel).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getLogLevelColor(logLevel),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getLogLevelColor(logLevel).withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getLogLevelColor(logLevel).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getLogLevelColor(logLevel).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        logLevel.name.toUpperCase(),
                        style: AppTextStyles.poppins(
                          color: _getLogLevelColor(logLevel),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _extractTimestamp(log),
                        style: AppTextStyles.poppins(
                          color: Colors.grey[400],
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _extractMessage(log),
                  style: AppTextStyles.poppins(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  SmppLogLevel _extractLogLevel(String log) {
    if (log.contains('[DEBUG]')) return SmppLogLevel.debug;
    if (log.contains('[INFO]')) return SmppLogLevel.info;
    if (log.contains('[WARNING]')) return SmppLogLevel.warning;
    if (log.contains('[ERROR]')) return SmppLogLevel.error;
    return SmppLogLevel.info;
  }

  String _extractTimestamp(String log) {
    final match = RegExp(r'\[(.*?)\]').firstMatch(log);
    return match?.group(1) ?? '';
  }

  String _extractMessage(String log) {
    final parts = log.split(']: ');
    return parts.length > 1 ? parts.sublist(1).join(']: ') : log;
  }

  void _clearLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Clear Logs',
          style: AppTextStyles.poppins(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to clear all SMPP logs?',
          style: AppTextStyles.poppins(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.poppins(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () {
              SmppLogger().clearLogs();
              _loadLogs();
              Navigator.pop(context);
            },
            child: Text(
              'Clear',
              style: AppTextStyles.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
