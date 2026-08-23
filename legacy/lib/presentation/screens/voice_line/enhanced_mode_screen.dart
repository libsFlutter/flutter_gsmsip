import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_line_provider.dart';
import '../../domain/models/voice_line_method.dart';
import '../../data/sources/voice_line/enhanced_mode_source.dart';

/// Экран настройки Enhanced Mode
class EnhancedModeScreen extends StatefulWidget {
  const EnhancedModeScreen({super.key});

  @override
  State<EnhancedModeScreen> createState() => _EnhancedModeScreenState();
}

class _EnhancedModeScreenState extends State<EnhancedModeScreen> {
  EnhancedModeStatus? _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final source = EnhancedModeSource();
      _status = await source.checkStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking status: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Mode'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_status == null) {
      return _buildErrorState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Description
          _buildDescriptionCard(),
          
          const SizedBox(height: 16),
          
          // Benefits
          _buildBenefitsCard(),
          
          const SizedBox(height: 16),
          
          // Requirements
          _buildRequirementsCard(),
          
          const SizedBox(height: 24),
          
          // Action button
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                const Text(
                  'Enhanced Audio Access',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Enables system-level audio access for optimal voice quality.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Benefits:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildBenefitItem('Direct digital audio path'),
            _buildBenefitItem('No acoustic coupling loss'),
            _buildBenefitItem('Best audio quality'),
            _buildBenefitItem('System-level integration'),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Why Enhanced Mode?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildComparisonRow('Audio Quality', '★★★★★', '★★★☆☆'),
            _buildComparisonRow('Latency', '< 5ms', '~20ms'),
            _buildComparisonRow('Echo', 'None', 'Possible'),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, String enhanced, String standard) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(
              enhanced,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text('vs'),
          Expanded(
            child: Text(
              standard,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Requirements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildRequirementItem(
              'System modifications enabled',
              _status?.magiskInstalled == true,
            ),
            _buildRequirementItem(
              'Privileged access available',
              _status?.privilegedPermissionsGranted == true,
            ),
            _buildRequirementItem(
              'Gateway app installed as system app',
              _status?.installedAsSystem == true,
            ),
            
            if (_status?.statusMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _status!.available
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _status!.available
                          ? Icons.check_circle
                          : Icons.info_outline,
                      color: _status!.available
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _status!.statusMessage!,
                        style: TextStyle(
                          color: _status!.available
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String title, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.cancel,
            color: met ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: met ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final available = _status?.available == true;
    
    if (available) {
      return ElevatedButton(
        onPressed: () => _enableEnhancedMode(),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Enable Enhanced Mode',
          style: TextStyle(fontSize: 16),
        ),
      );
    } else {
      return Column(
        children: [
          Text(
            'Enhanced Mode not available on this device',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showAlternativeMethods(),
            icon: const Icon(Icons.alt_route),
            label: const Text('Alternative Methods'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _contactSupport(),
            icon: const Icon(Icons.support),
            label: const Text('Contact Support'),
          ),
        ],
      );
    }
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check, size: 16, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Text(benefit),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to check Enhanced Mode status',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkStatus,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _enableEnhancedMode() {
    final provider = context.read<VoiceLineProvider>();
    provider.setMethod(VoiceLineMethod.enhancedMode);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enhanced Mode Enabled'),
        content: const Text(
          'Enhanced Mode has been selected. A device restart may be required for changes to take effect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAlternativeMethods() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alternative Methods'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Consider these alternatives:'),
            const SizedBox(height: 12),
            _buildAlternativeItem(
              'Dongle',
              'USB-C or TRRS adapter for high quality audio',
            ),
            _buildAlternativeItem(
              'Telecom API',
              'Standard Android API, works on all devices',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text(
          'For assistance with Enhanced Mode installation, please contact our support team.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              // Open support contact
              Navigator.pop(context);
            },
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }
}
