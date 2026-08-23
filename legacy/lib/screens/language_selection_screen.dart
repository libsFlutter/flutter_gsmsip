import 'package:flutter/material.dart';
import '../utils/text_styles.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  void _loadCurrentLanguage() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    _selectedLanguage = languageProvider.currentLocale.languageCode;
  }

  Future<void> _changeLanguage(String languageCode) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    await languageProvider.setLanguage(languageCode);
    
    setState(() {
      _selectedLanguage = languageCode;
    });

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language changed to ${languageProvider.getLanguageName(languageCode)}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        elevation: 0,
        title: Text(
          'Language',
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
      body: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: languageProvider.supportedLanguages.length,
            itemBuilder: (context, index) {
              final language = languageProvider.supportedLanguages[index];
              final languageCode = language['code']!;
              final languageName = language['name']!;
              final isSelected = languageCode == _selectedLanguage;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: const Color(0xFF2A2A2A),
                child: ListTile(
                  leading: Icon(
                    Icons.language,
                    color: isSelected ? Colors.blue[400] : Colors.grey[400],
                  ),
                  title: Text(
                    languageName,
                    style: AppTextStyles.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    languageCode.toUpperCase(),
                    style: AppTextStyles.poppins(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.blue[400],
                        )
                      : null,
                  onTap: () => _changeLanguage(languageCode),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 