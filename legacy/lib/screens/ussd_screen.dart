import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/text_styles.dart';
import '../providers/gateway_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UssdScreen extends StatefulWidget {
  const UssdScreen({Key? key}) : super(key: key);

  @override
  State<UssdScreen> createState() => _UssdScreenState();
}

class _UssdScreenState extends State<UssdScreen> {
  final TextEditingController _ussdController = TextEditingController();
  final List<String> _ussdHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: Text(
          'USSD',
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
      body: Column(
        children: [
          _buildUssdInput(),
          _buildCommonCodes(),
          Expanded(
            child: _buildHistory(),
          ),
        ],
      ),
    );
  }

  Widget _buildUssdInput() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'USSD Request',
            style: AppTextStyles.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ussdController,
            style: AppTextStyles.poppins(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'USSD Code (e.g., *100#)',
              labelStyle: AppTextStyles.poppins(color: Colors.grey[400]),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isLoading ? Icons.hourglass_empty : Icons.send,
                  color: _isLoading ? Colors.grey : Colors.blue,
                ),
                onPressed: _isLoading ? null : _sendUssdRequest,
              ),
            ),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _sendUssdRequest(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonCodes() {
    return Consumer<GatewayProvider>(
      builder: (context, provider, child) {
        final commonCodes = provider.getCommonUssdCodes();
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Common USSD Codes',
                style: AppTextStyles.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: commonCodes.map((code) {
                  return InkWell(
                    onTap: () {
                      _ussdController.text = code;
                      _sendUssdRequest();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        code,
                        style: AppTextStyles.poppins(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistory() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'USSD History',
            style: AppTextStyles.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _ussdHistory.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _ussdHistory.length,
                    itemBuilder: (context, index) {
                      final historyItem = _ussdHistory[index];
                      return _buildHistoryItem(historyItem);
                    },
                  ),
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
            Icons.phone_android_outlined,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No USSD requests yet',
            style: AppTextStyles.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send your first USSD request above',
            style: AppTextStyles.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String historyItem) {
    final parts = historyItem.split('|');
    if (parts.length < 3) return const SizedBox.shrink();

    final timestamp = parts[0];
    final code = parts[1];
    final response = parts[2];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.phone_android,
                    color: Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    code,
                    style: AppTextStyles.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                timestamp,
                style: AppTextStyles.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              response,
              style: AppTextStyles.poppins(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendUssdRequest() async {
    final ussdCode = _ussdController.text.trim();
    if (ussdCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a USSD code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<GatewayProvider>(context, listen: false);
      final response = await provider.sendUssdRequest(ussdCode);

      if (response != null) {
        final timestamp = DateTime.now().toString().substring(11, 19);
        final historyItem = '$timestamp|$ussdCode|$response';
        
        setState(() {
          _ussdHistory.insert(0, historyItem);
          if (_ussdHistory.length > 50) {
            _ussdHistory.removeLast();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('USSD request sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send USSD request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _ussdController.dispose();
    super.dispose();
  }
}
