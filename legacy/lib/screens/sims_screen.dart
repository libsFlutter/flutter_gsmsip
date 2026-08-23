import 'package:flutter/material.dart';
import '../utils/text_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SimsScreen extends StatefulWidget {
  const SimsScreen({Key? key}) : super(key: key);

  @override
  State<SimsScreen> createState() => _SimsScreenState();
}

class _SimsScreenState extends State<SimsScreen> {
  final List<SimCard> _simCards = [];
  final List<PhoneLine> _phoneLines = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    _simCards.addAll([
      SimCard(
        id: '1',
        name: 'Primary SIM',
        iccid: '89014103211118510720',
        imsi: '250012345678901',
        type: SimType.physical,
        status: SimStatus.active,
        operator: 'MTS',
        balance: 150.75,
        assignedLine: '1',
        signalStrength: 85,
      ),
      SimCard(
        id: '2',
        name: 'Backup eSIM',
        iccid: '89014103211118510721',
        imsi: '250012345678902',
        type: SimType.esim,
        status: SimStatus.inactive,
        operator: 'Beeline',
        balance: 45.20,
        assignedLine: null,
        signalStrength: 0,
      ),
      SimCard(
        id: '3',
        name: 'Remote SIM',
        iccid: '89014103211118510722',
        imsi: '250012345678903',
        type: SimType.remote,
        status: SimStatus.active,
        operator: 'Megafon',
        balance: 89.50,
        assignedLine: '3',
        signalStrength: 65,
      ),
    ]);

    _phoneLines.addAll([
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
          'SIM Cards',
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
            onPressed: _refreshSims,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddSimDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCard(),
          Expanded(
            child: _simCards.isEmpty
                ? _buildEmptyState()
                : _buildSimsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final activeSims = _simCards.where((sim) => sim.status == SimStatus.active).length;
    final physicalSims = _simCards.where((sim) => sim.type == SimType.physical).length;
    final esimCount = _simCards.where((sim) => sim.type == SimType.esim).length;
    final remoteSims = _simCards.where((sim) => sim.type == SimType.remote).length;

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
              icon: Icons.sim_card,
              label: 'Total SIMs',
              value: '${_simCards.length}',
              color: Colors.blue,
              tooltip: 'Total number of SIM cards in the system',
            ),
          ),
          Expanded(
            child: _buildStatItemWithTooltip(
              icon: Icons.check_circle,
              label: 'Active',
              value: '$activeSims',
              color: Colors.green,
              tooltip: 'Number of currently active SIM cards',
            ),
          ),
          Expanded(
            child: _buildStatItemWithTooltip(
              icon: Icons.phone_android,
              label: 'Physical/eSIM/Remote',
              value: '$physicalSims/$esimCount/$remoteSims',
              color: Colors.orange,
              tooltip: 'Physical SIM cards / eSIM / Remote SIM cards',
            ),
          ),
        ],
      ),
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
            Icons.sim_card,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No SIM cards',
            style: AppTextStyles.poppinsBold(
              fontSize: 18,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first SIM card',
            style: AppTextStyles.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _simCards.length,
      itemBuilder: (context, index) {
        final sim = _simCards[index];
        return _buildSimCard(sim);
      },
    );
  }

  Widget _buildSimCard(SimCard sim) {
    final assignedLine = _phoneLines.where((line) => line.id == sim.assignedLine).firstOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: sim.status == SimStatus.active
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
                _getSimTypeIcon(sim.type),
                color: _getSimTypeColor(sim.type),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sim.name,
                      style: AppTextStyles.poppinsBold(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      sim.operator,
                      style: AppTextStyles.poppins(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusIndicator(sim.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSimInfoWithTooltip(
                  icon: Icons.signal_cellular_alt,
                  label: 'Signal',
                  value: '${sim.signalStrength}%',
                  color: Colors.blue,
                  tooltip: 'Signal strength (0-100%)',
                ),
              ),
              Expanded(
                child: _buildSimInfoWithTooltip(
                  icon: Icons.account_balance_wallet,
                  label: 'Balance',
                  value: '\$${sim.balance.toStringAsFixed(2)}',
                  color: Colors.orange,
                  tooltip: 'Available balance on this SIM card',
                ),
              ),
              Expanded(
                child: _buildSimInfoWithTooltip(
                  icon: Icons.phone,
                  label: 'Assigned Line',
                  value: assignedLine?.name ?? 'None',
                  color: Colors.green,
                  tooltip: 'Phone line this SIM is assigned to',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.settings,
                  label: 'Settings',
                  color: Colors.grey,
                  onTap: () => _showSimSettings(sim),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.swap_horiz,
                  label: 'Assign',
                  color: Colors.blue,
                  onTap: () => _showAssignSimDialog(sim),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: sim.status == SimStatus.active ? Icons.pause : Icons.play_arrow,
                  label: sim.status == SimStatus.active ? 'Disable' : 'Enable',
                  color: sim.status == SimStatus.active ? Colors.red : Colors.green,
                  onTap: () => _toggleSim(sim),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(SimStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case SimStatus.active:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case SimStatus.inactive:
        icon = Icons.pause_circle;
        color = Colors.grey;
        break;
      case SimStatus.error:
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

  Widget _buildSimInfoWithTooltip({
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

  IconData _getSimTypeIcon(SimType type) {
    switch (type) {
      case SimType.physical:
        return Icons.sim_card;
      case SimType.esim:
        return Icons.phone_android;
      case SimType.remote:
        return Icons.cloud;
    }
  }

  Color _getSimTypeColor(SimType type) {
    switch (type) {
      case SimType.physical:
        return Colors.green;
      case SimType.esim:
        return Colors.blue;
      case SimType.remote:
        return Colors.orange;
    }
  }

  void _showAddSimDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Add SIM Card',
          style: AppTextStyles.poppinsBold(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.sim_card, color: Colors.green),
              title: Text(
                'Physical SIM',
                style: AppTextStyles.poppins(color: Colors.white),
              ),
              subtitle: Text(
                'Add a physical SIM card',
                style: AppTextStyles.poppins(color: Colors.grey[400]),
              ),
              onTap: () {
                Navigator.pop(context);
                _addSim(SimType.physical);
              },
            ),
            ListTile(
              leading: Icon(Icons.phone_android, color: Colors.blue),
              title: Text(
                'eSIM',
                style: AppTextStyles.poppins(color: Colors.white),
              ),
              subtitle: Text(
                'Add an embedded SIM card',
                style: AppTextStyles.poppins(color: Colors.grey[400]),
              ),
              onTap: () {
                Navigator.pop(context);
                _addSim(SimType.esim);
              },
            ),
            ListTile(
              leading: Icon(Icons.cloud, color: Colors.orange),
              title: Text(
                'Remote SIM',
                style: AppTextStyles.poppins(color: Colors.white),
              ),
              subtitle: Text(
                'Add a remote SIM card',
                style: AppTextStyles.poppins(color: Colors.grey[400]),
              ),
              onTap: () {
                Navigator.pop(context);
                _addSim(SimType.remote);
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

  void _addSim(SimType type) {
    final newSim = SimCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'New ${type == SimType.physical ? 'Physical' : type == SimType.esim ? 'eSIM' : 'Remote'} SIM',
      iccid: '89014103211118510${DateTime.now().millisecondsSinceEpoch}',
      imsi: '2500123456789${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      status: SimStatus.inactive,
      operator: 'Unknown',
      balance: 0.0,
      assignedLine: null,
      signalStrength: 0,
    );

    setState(() {
      _simCards.add(newSim);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${type == SimType.physical ? 'Physical' : type == SimType.esim ? 'eSIM' : 'Remote'} SIM added'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAssignSimDialog(SimCard sim) {
    final availableLines = _phoneLines.where((line) => 
      line.type == LineType.gsm && 
      (line.assignedSim == null || line.assignedSim == sim.id)
    ).toList();

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
              'Select a line to assign "${sim.name}" to:',
              style: AppTextStyles.poppins(color: Colors.grey[300]),
            ),
            const SizedBox(height: 16),
            ...availableLines.map((line) => ListTile(
              leading: Icon(
                Icons.phone,
                color: line.assignedSim == sim.id ? Colors.green : Colors.blue,
              ),
              title: Text(
                line.name,
                style: AppTextStyles.poppins(color: Colors.white),
              ),
              subtitle: Text(
                line.assignedSim == sim.id ? 'Currently assigned' : 'Available',
                style: AppTextStyles.poppins(color: Colors.grey[400]),
              ),
              onTap: () {
                Navigator.pop(context);
                _assignSimToLine(sim, line);
              },
            )),
            if (availableLines.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No available GSM lines',
                  style: AppTextStyles.poppins(color: Colors.grey[400]),
                ),
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

  void _assignSimToLine(SimCard sim, PhoneLine line) {
    setState(() {
      // Remove SIM from current line if assigned
      if (sim.assignedLine != null) {
        final currentLine = _phoneLines.firstWhere((l) => l.id == sim.assignedLine);
        currentLine.assignedSim = null;
      }

      // Remove other SIM from target line if assigned
      if (line.assignedSim != null) {
        final otherSim = _simCards.firstWhere((s) => s.id == line.assignedSim);
        otherSim.assignedLine = null;
      }

      // Assign SIM to new line
      sim.assignedLine = line.id;
      line.assignedSim = sim.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${sim.name} assigned to ${line.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSimSettings(SimCard sim) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening settings for ${sim.name}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _toggleSim(SimCard sim) {
    setState(() {
      sim.status = sim.status == SimStatus.active
          ? SimStatus.inactive
          : SimStatus.active;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${sim.name} ${sim.status == SimStatus.active ? 'enabled' : 'disabled'}'),
        backgroundColor: sim.status == SimStatus.active ? Colors.green : Colors.orange,
      ),
    );
  }

  void _refreshSims() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SIM cards refreshed'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

enum SimStatus { active, inactive, error }
enum SimType { physical, esim, remote }

class SimCard {
  final String id;
  final String name;
  final String iccid;
  final String imsi;
  final SimType type;
  SimStatus status;
  final String operator;
  final double balance;
  String? assignedLine;
  int signalStrength;

  SimCard({
    required this.id,
    required this.name,
    required this.iccid,
    required this.imsi,
    required this.type,
    required this.status,
    required this.operator,
    required this.balance,
    this.assignedLine,
    required this.signalStrength,
  });
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