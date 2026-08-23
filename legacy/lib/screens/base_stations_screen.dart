import 'package:flutter/material.dart';
import '../utils/text_styles.dart';

class BaseStation {
  final String lac;
  final String cellId;
  final String operator;
  final String signalStrength;
  final String status;
  final int connectedLines;
  final String lastSeen;
  final String location;

  BaseStation({
    required this.lac,
    required this.cellId,
    required this.operator,
    required this.signalStrength,
    required this.status,
    required this.connectedLines,
    required this.lastSeen,
    required this.location,
  });
}

class BaseStationsScreen extends StatefulWidget {
  const BaseStationsScreen({Key? key}) : super(key: key);

  @override
  State<BaseStationsScreen> createState() => _BaseStationsScreenState();
}

class _BaseStationsScreenState extends State<BaseStationsScreen> {
  List<BaseStation> baseStations = [];
  String selectedFilter = 'All';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBaseStations();
  }

  void _loadBaseStations() {
    setState(() {
      isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        baseStations = [
          BaseStation(
            lac: '12345',
            cellId: '67890',
            operator: 'MTS',
            signalStrength: '-65 dBm',
            status: 'Active',
            connectedLines: 3,
            lastSeen: '2 min ago',
            location: 'Moscow, Russia',
          ),
          BaseStation(
            lac: '12346',
            cellId: '67891',
            operator: 'Beeline',
            signalStrength: '-72 dBm',
            status: 'Active',
            connectedLines: 2,
            lastSeen: '5 min ago',
            location: 'Moscow, Russia',
          ),
          BaseStation(
            lac: '12347',
            cellId: '67892',
            operator: 'Megafon',
            signalStrength: '-78 dBm',
            status: 'Weak',
            connectedLines: 1,
            lastSeen: '10 min ago',
            location: 'Moscow, Russia',
          ),
          BaseStation(
            lac: '12348',
            cellId: '67893',
            operator: 'Tele2',
            signalStrength: '-85 dBm',
            status: 'Inactive',
            connectedLines: 0,
            lastSeen: '1 hour ago',
            location: 'Moscow, Russia',
          ),
          BaseStation(
            lac: '12349',
            cellId: '67894',
            operator: 'MTS',
            signalStrength: '-68 dBm',
            status: 'Active',
            connectedLines: 4,
            lastSeen: '1 min ago',
            location: 'Moscow, Russia',
          ),
        ];
        isLoading = false;
      });
    });
  }

  List<BaseStation> get filteredStations {
    if (selectedFilter == 'All') return baseStations;
    return baseStations.where((station) => station.status == selectedFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'weak':
        return Colors.orange;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.cell_tower,
              color: Colors.blue[400],
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Base Stations',
              style: AppTextStyles.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadBaseStations,
            icon: Icon(
              Icons.refresh,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCards(),
          _buildFilterChips(),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  )
                : _buildStationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final activeStations = baseStations.where((s) => s.status == 'Active').length;
    final totalLines = baseStations.fold(0, (sum, station) => sum + station.connectedLines);
    final avgSignal = baseStations.isNotEmpty
        ? baseStations.map((s) => int.tryParse(s.signalStrength.split(' ')[0]) ?? 0).reduce((a, b) => a + b) / baseStations.length
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCardWithTooltip(
              icon: Icons.cell_tower,
              title: 'Active BS',
              value: '$activeStations',
              color: Colors.green,
              tooltip: 'Number of active base stations',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCardWithTooltip(
              icon: Icons.phone,
              title: 'Connected Lines',
              value: '$totalLines',
              color: Colors.blue,
              tooltip: 'Total lines connected to base stations',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCardWithTooltip(
              icon: Icons.signal_cellular_4_bar,
              title: 'Avg Signal',
              value: '${avgSignal.round()} dBm',
              color: Colors.orange,
              tooltip: 'Average signal strength across all stations',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardWithTooltip({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[800] ?? Colors.grey,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.poppins(
                fontSize: 12,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Active', 'Weak', 'Inactive'];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter,
                style: AppTextStyles.poppins(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.grey[400],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
                });
              },
              backgroundColor: const Color(0xFF2A2A2A),
              selectedColor: Colors.blue[600] ?? Colors.blue,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? (Colors.blue[600] ?? Colors.blue) : (Colors.grey[700] ?? Colors.grey),
                width: 1,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStationsList() {
    if (filteredStations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cell_tower_outlined,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No base stations found',
              style: AppTextStyles.poppins(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredStations.length,
      itemBuilder: (context, index) {
        final station = filteredStations[index];
        return _buildStationCard(station);
      },
    );
  }

  Widget _buildStationCard(BaseStation station) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[800] ?? Colors.grey,
          width: 1,
        ),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(station.status).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.cell_tower,
            color: _getStatusColor(station.status),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LAC: ${station.lac} • CELL: ${station.cellId}',
                    style: AppTextStyles.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    station.operator,
                    style: AppTextStyles.poppins(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(station.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                station.status,
                style: AppTextStyles.poppins(
                  fontSize: 10,
                  color: _getStatusColor(station.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              _buildInfoChip(
                icon: Icons.signal_cellular_4_bar,
                label: station.signalStrength,
                tooltip: 'Signal strength in dBm',
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                icon: Icons.phone,
                label: '${station.connectedLines} lines',
                tooltip: 'Number of connected phone lines',
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                icon: Icons.access_time,
                label: station.lastSeen,
                tooltip: 'Last activity time',
              ),
            ],
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Location', station.location),
                _buildDetailRow('Operator', station.operator),
                _buildDetailRow('Signal Strength', station.signalStrength),
                _buildDetailRow('Connected Lines', '${station.connectedLines}'),
                _buildDetailRow('Last Seen', station.lastSeen),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showDetailedMetrics(station);
                        },
                        icon: const Icon(Icons.analytics, size: 16),
                        label: Text(
                          'View Metrics',
                          style: AppTextStyles.poppins(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600] ?? Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showConnectedLines(station);
                        },
                        icon: const Icon(Icons.phone, size: 16),
                        label: Text(
                          'Connected Lines',
                          style: AppTextStyles.poppins(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600] ?? Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[800] ?? Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.poppins(
                fontSize: 10,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.poppins(
                fontSize: 12,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.poppins(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Показать детальные метрики базовой станции
  void _showDetailedMetrics(dynamic station) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detailed Metrics - ${station.name ?? 'Base Station'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMetricRow('Signal Strength', '${station.signalStrength ?? 'N/A'} dBm'),
              _buildMetricRow('Cell ID', '${station.cellId ?? 'N/A'}'),
              _buildMetricRow('LAC', '${station.lac ?? 'N/A'}'),
              _buildMetricRow('MCC', '${station.mcc ?? 'N/A'}'),
              _buildMetricRow('MNC', '${station.mnc ?? 'N/A'}'),
              _buildMetricRow('Technology', '${station.technology ?? 'N/A'}'),
              _buildMetricRow('Frequency', '${station.frequency ?? 'N/A'} MHz'),
              _buildMetricRow('Bandwidth', '${station.bandwidth ?? 'N/A'} MHz'),
              _buildMetricRow('RSRP', '${station.rsrp ?? 'N/A'} dBm'),
              _buildMetricRow('RSRQ', '${station.rsrq ?? 'N/A'} dB'),
              _buildMetricRow('SINR', '${station.sinr ?? 'N/A'} dB'),
              _buildMetricRow('Last Updated', '${station.lastUpdated ?? 'N/A'}'),
            ],
          ),
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

  /// Построить строку метрики
  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.poppins(
              fontSize: 14,
              color: Colors.blue[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Показать подключенные линии
  void _showConnectedLines(dynamic station) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connected Lines - ${station.name ?? 'Base Station'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Active Connections:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildLineItem('SIP Line 1', 'Connected', Colors.green),
              _buildLineItem('SIP Line 2', 'Connected', Colors.green),
              _buildLineItem('GSM Line 1', 'Connected', Colors.green),
              _buildLineItem('GSM Line 2', 'Disconnected', Colors.red),
              _buildLineItem('VoIP Line', 'Connected', Colors.green),
              const SizedBox(height: 12),
              const Text(
                'Connection Details:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildConnectionDetail('Total Lines', '5'),
              _buildConnectionDetail('Active Lines', '4'),
              _buildConnectionDetail('Failed Lines', '1'),
              _buildConnectionDetail('Last Update', DateTime.now().toString().substring(0, 19)),
            ],
          ),
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

  /// Построить элемент линии
  Widget _buildLineItem(String name, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: AppTextStyles.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              status,
              style: AppTextStyles.poppins(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Построить деталь подключения
  Widget _buildConnectionDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.poppins(
              fontSize: 14,
              color: Colors.blue[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 