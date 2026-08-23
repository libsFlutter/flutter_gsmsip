import 'package:flutter/material.dart';
import '../utils/text_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LinesScreen extends StatefulWidget {
  const LinesScreen({Key? key}) : super(key: key);

  @override
  State<LinesScreen> createState() => _LinesScreenState();
}

class _LinesScreenState extends State<LinesScreen> {
  final List<PhoneLine> _lines = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMockLines();
  }

  void _loadMockLines() {
    _lines.addAll([
      PhoneLine(
        id: '1',
        name: 'Primary Line',
        number: '+1234567890',
        status: LineStatus.active,
        type: LineType.gsm,
        signalStrength: 85,
        balance: 25.50,
        lastCall: DateTime.now().subtract(const Duration(minutes: 30)),
        assignedSim: '1',
      ),
      PhoneLine(
        id: '2',
        name: 'Secondary Line',
        number: '+0987654321',
        status: LineStatus.inactive,
        type: LineType.sip,
        signalStrength: 0,
        balance: 0.0,
        lastCall: DateTime.now().subtract(const Duration(hours: 2)),
        assignedSim: null,
      ),
      PhoneLine(
        id: '3',
        name: 'Backup Line',
        number: '+1122334455',
        status: LineStatus.active,
        type: LineType.gsm,
        signalStrength: 65,
        balance: 12.75,
        lastCall: DateTime.now().subtract(const Duration(days: 1)),
        assignedSim: '3',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: Text(
          'Phone Lines',
          style: AppTextStyles.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshLines,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddLineDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCard(),
          Expanded(
            child: _lines.isEmpty
                ? _buildEmptyState()
                : _buildLinesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final activeLines = _lines.where((line) => line.status == LineStatus.active).length;
    final gsmLines = _lines.where((line) => line.type == LineType.gsm).length;
    final sipLines = _lines.where((line) => line.type == LineType.sip).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItemWithTooltip(
              icon: Icons.phone,
              label: 'Total Lines',
              value: '${_lines.length}',
              color: Colors.blue,
              tooltip: 'Total number of configured phone lines',
            ),
          ),
          Expanded(
            child: _buildStatItemWithTooltip(
              icon: Icons.check_circle,
              label: 'Active',
              value: '$activeLines',
              color: Colors.green,
              tooltip: 'Number of currently active phone lines',
            ),
          ),
          Expanded(
            child: _buildStatItemWithTooltip(
              icon: Icons.router,
              label: 'GSM/SIP',
              value: '$gsmLines/$sipLines',
              color: Colors.orange,
              tooltip: 'GSM (mobile) and SIP (VoIP) line count',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.poppinsBold(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.poppins(
            fontSize: 12,
            color: Colors.grey[400],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatItemWithTooltip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
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
            style: AppTextStyles.poppinsBold(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.poppins(
              fontSize: 12,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.phone,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No phone lines',
            style: AppTextStyles.poppinsBold(
              fontSize: 18,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first phone line',
            style: AppTextStyles.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _lines.length,
      itemBuilder: (context, index) {
        final line = _lines[index];
        return _buildLineCard(line);
      },
    );
  }

  Widget _buildLineCard(PhoneLine line) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: line.status == LineStatus.active
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                line.type == LineType.gsm ? Icons.phone_android : Icons.router,
                color: line.type == LineType.gsm ? Colors.green : Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.name,
                      style: AppTextStyles.poppinsBold(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      line.number,
                      style: AppTextStyles.poppins(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusIndicator(line.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLineInfoWithTooltip(
                  icon: Icons.signal_cellular_alt,
                  label: 'Signal',
                  value: line.type == LineType.gsm ? '${line.signalStrength}%' : 'N/A',
                  color: Colors.blue,
                  tooltip: line.type == LineType.gsm ? 'GSM signal strength (0-100%)' : 'Signal strength not applicable for SIP',
                ),
              ),
              Expanded(
                child: _buildLineInfoWithTooltip(
                  icon: Icons.account_balance_wallet,
                  label: 'Balance',
                  value: '\$${line.balance.toStringAsFixed(2)}',
                  color: Colors.orange,
                  tooltip: 'Available balance for this phone line',
                ),
              ),
              Expanded(
                child: _buildLineInfoWithTooltip(
                  icon: Icons.call,
                  label: 'Last Call',
                  value: _formatLastCall(line.lastCall),
                  color: Colors.green,
                  tooltip: 'Time since the last call on this line',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.call,
                  label: 'Call',
                  color: Colors.blue,
                  onTap: () => _makeCall(line),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.settings,
                  label: 'Settings',
                  color: Colors.grey,
                  onTap: () => _showLineSettings(line),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.sim_card,
                  label: 'SIM',
                  color: Colors.blue,
                  onTap: () => _showAssignSimDialog(line),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: line.status == LineStatus.active ? Icons.pause : Icons.play_arrow,
                  label: line.status == LineStatus.active ? 'Disable' : 'Enable',
                  color: line.status == LineStatus.active ? Colors.red : Colors.green,
                  onTap: () => _toggleLine(line),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(LineStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case LineStatus.active:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case LineStatus.inactive:
        icon = Icons.pause_circle;
        color = Colors.grey;
        break;
      case LineStatus.error:
        icon = Icons.error;
        color = Colors.red;
        break;
    }

    return Icon(
      icon,
      color: color,
      size: 20,
    );
  }

  Widget _buildLineInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.poppinsBold(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.poppins(
            fontSize: 10,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildLineInfoWithTooltip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.poppinsBold(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.poppins(
              fontSize: 10,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.poppins(
                fontSize: 10,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLineDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Add Phone Line',
          style: AppTextStyles.poppinsBold(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.phone_android, color: Colors.green),
              title: Text(
                'GSM Line',
                style: AppTextStyles.poppins(color: Colors.white),
              ),
              subtitle: Text(
                'Add a GSM phone line',
                style: AppTextStyles.poppins(color: Colors.grey[400]),
              ),
              onTap: () {
                Navigator.pop(context);
                _addLine(LineType.gsm);
              },
            ),
            ListTile(
              leading: Icon(Icons.router, color: Colors.blue),
              title: Text(
                'SIP Line',
                style: AppTextStyles.poppins(color: Colors.white),
              ),
              subtitle: Text(
                'Add a SIP phone line',
                style: AppTextStyles.poppins(color: Colors.grey[400]),
              ),
              onTap: () {
                Navigator.pop(context);
                _addLine(LineType.sip);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.poppins(color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  void _addLine(LineType type) {
    final newLine = PhoneLine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'New ${type == LineType.gsm ? 'GSM' : 'SIP'} Line',
      number: '+${DateTime.now().millisecondsSinceEpoch}',
      status: LineStatus.inactive,
      type: type,
      signalStrength: type == LineType.gsm ? 0 : 0,
      balance: 0.0,
      lastCall: null,
    );

    setState(() {
      _lines.add(newLine);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${type == LineType.gsm ? 'GSM' : 'SIP'} line added'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _makeCall(PhoneLine line) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Making call from ${line.name}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showLineSettings(PhoneLine line) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening settings for ${line.name}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showAssignSimDialog(PhoneLine line) {
    // Mock available SIMs - in real app this would come from a provider
    final availableSims = [
      {'id': '1', 'name': 'Primary SIM', 'type': 'Physical'},
      {'id': '2', 'name': 'Backup eSIM', 'type': 'eSIM'},
      {'id': '3', 'name': 'Remote SIM', 'type': 'Remote'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Assign SIM to Line',
          style: AppTextStyles.poppinsBold(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select a SIM card for "${line.name}":',
              style: AppTextStyles.poppins(color: Colors.grey[300]),
            ),
            const SizedBox(height: 16),
            ...availableSims.map((sim) => ListTile(
              leading: Icon(
                Icons.sim_card,
                color: line.assignedSim == sim['id'] ? Colors.green : Colors.blue,
              ),
              title: Text(
                sim['name']!,
                style: AppTextStyles.poppins(color: Colors.white),
              ),
              subtitle: Text(
                sim['type']!,
                style: AppTextStyles.poppins(color: Colors.grey[400]),
              ),
              onTap: () {
                Navigator.pop(context);
                _assignSimToLine(line, sim['id']!);
              },
            )),
            ListTile(
              leading: Icon(Icons.remove_circle, color: Colors.red),
              title: Text(
                'Remove SIM',
                style: AppTextStyles.poppins(color: Colors.white),
              ),
              subtitle: Text(
                'Remove current SIM assignment',
                style: AppTextStyles.poppins(color: Colors.grey[400]),
              ),
              onTap: () {
                Navigator.pop(context);
                _removeSimFromLine(line);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.poppins(color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  void _assignSimToLine(PhoneLine line, String simId) {
    setState(() {
      line.assignedSim = simId;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SIM assigned to ${line.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeSimFromLine(PhoneLine line) {
    setState(() {
      line.assignedSim = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SIM removed from ${line.name}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _toggleLine(PhoneLine line) {
    setState(() {
      line.status = line.status == LineStatus.active
          ? LineStatus.inactive
          : LineStatus.active;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${line.name} ${line.status == LineStatus.active ? 'enabled' : 'disabled'}'),
        backgroundColor: line.status == LineStatus.active ? Colors.green : Colors.orange,
      ),
    );
  }

  void _refreshLines() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lines refreshed'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String _formatLastCall(DateTime? lastCall) {
    if (lastCall == null) return 'Never';
    
    final now = DateTime.now();
    final difference = now.difference(lastCall);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

enum LineStatus { active, inactive, error }
enum LineType { gsm, sip }

class PhoneLine {
  final String id;
  final String name;
  final String number;
  LineStatus status;
  final LineType type;
  final int signalStrength;
  final double balance;
  final DateTime? lastCall;
  String? assignedSim;

  PhoneLine({
    required this.id,
    required this.name,
    required this.number,
    required this.status,
    required this.type,
    required this.signalStrength,
    required this.balance,
    this.lastCall,
    this.assignedSim,
  });
} 