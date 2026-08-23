import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../utils/text_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  Map<String, String> _deviceInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceInfo = {
          'Device Model': androidInfo.model,
          'Manufacturer': androidInfo.manufacturer,
          'Android Version': androidInfo.version.release,
          'SDK Level': androidInfo.version.sdkInt.toString(),
          'Device ID': androidInfo.id,
          'Brand': androidInfo.brand,
          'Product': androidInfo.product,
          'Hardware': androidInfo.hardware,
          'Fingerprint': androidInfo.fingerprint,
        };
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceInfo = {
          'Device Name': iosInfo.name,
          'Model': iosInfo.model,
          'System Name': iosInfo.systemName,
          'System Version': iosInfo.systemVersion,
          'Device ID': iosInfo.identifierForVendor ?? 'Unknown',
        };
      }
    } catch (e) {
      _deviceInfo = {
        'Error': 'Failed to load device info: $e',
      };
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: Text(
          'Device Info',
          style: AppTextStyles.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppInfo(),
                  const SizedBox(height: 24),
                  _buildDeviceInfo(),
                  const SizedBox(height: 24),
                  _buildSystemInfo(),
                  const SizedBox(height: 24),
                  _buildAboutSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.router,
                  color: Colors.blue[400],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GOSTsimbox Gateway',
                      style: AppTextStyles.poppinsBold(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 2.0.4',
                      style: AppTextStyles.poppins(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Tooltip(
            message: 'GSM: Global System for Mobile communications\nSIP: Session Initiation Protocol for VoIP calls',
            child: Text(
              'Bidirectional bridge between GSM telephony and SIP protocol',
              style: AppTextStyles.poppins(
                fontSize: 14,
                color: Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.phone_android,
                color: Colors.green[400],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Device Information',
                style: AppTextStyles.poppinsBold(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._deviceInfo.entries.map((entry) => _buildInfoRow(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildSystemInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                color: Colors.orange[400],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'System Information',
                style: AppTextStyles.poppinsBold(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Platform', Theme.of(context).platform.toString()),
          _buildInfoRow('Theme', 'Dark'),
          _buildInfoRow('Locale', Localizations.localeOf(context).toString()),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code,
                color: Colors.purple[400],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'About',
                style: AppTextStyles.poppinsBold(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'This application provides a bridge between GSM telephony and SIP protocol, allowing seamless communication between traditional phone systems and modern VoIP networks.',
            style: AppTextStyles.poppins(
              fontSize: 14,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Features:',
            style: AppTextStyles.poppinsBold(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          _buildFeatureItemWithTooltip('• Bidirectional call routing', 'Calls can flow in both directions between GSM and SIP networks'),
          _buildFeatureItemWithTooltip('• Real-time call monitoring', 'Live tracking of active calls and their status'),
          _buildFeatureItemWithTooltip('• Quality metrics tracking', 'Monitoring call quality using MOS, latency, and packet loss'),
          _buildFeatureItemWithTooltip('• Multi-language support', 'Interface available in multiple languages'),
          _buildFeatureItemWithTooltip('• Advanced analytics', 'Detailed call statistics and performance analysis'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.poppins(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: AppTextStyles.poppins(
          fontSize: 14,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildFeatureItemWithTooltip(String text, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: AppTextStyles.poppins(
            fontSize: 14,
            color: Colors.grey[300],
          ),
        ),
      ),
    );
  }
} 