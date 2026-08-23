import 'package:flutter/material.dart';
import '../utils/text_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/storage_service.dart';

typedef LocaleChangedCallback = void Function(String languageCode);

class LanguageScreen extends StatefulWidget {
  final LocaleChangedCallback? onLocaleChanged;
  const LanguageScreen({Key? key, this.onLocaleChanged}) : super(key: key);

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'en';
  final StorageService _storage = StorageService();

  final Map<String, Map<String, String>> _languages = {
    'en': {'name': 'English', 'native': 'English'},
    'ru': {'name': 'Russian', 'native': 'Русский'},
    'es': {'name': 'Spanish', 'native': 'Español'},
    'fr': {'name': 'French', 'native': 'Français'},
    'de': {'name': 'German', 'native': 'Deutsch'},
    'zh': {'name': 'Chinese', 'native': '中文'},
    'ja': {'name': 'Japanese', 'native': '日本語'},
    'ko': {'name': 'Korean', 'native': '한국어'},
    'ar': {'name': 'Arabic', 'native': 'العربية'},
    'pt': {'name': 'Portuguese', 'native': 'Português'},
    'it': {'name': 'Italian', 'native': 'Italiano'},
    'th': {'name': 'Thai', 'native': 'ไทย'},
    'tg': {'name': 'Tajik', 'native': 'Тоҷикӣ'},
    'az': {'name': 'Azerbaijani', 'native': 'Azərbaycan'},
    'km': {'name': 'Khmer', 'native': 'ខ្មែរ'},
    'lo': {'name': 'Lao', 'native': 'ລາວ'},
    'my': {'name': 'Myanmar', 'native': 'မြန်မာ'},
    'ms': {'name': 'Malay', 'native': 'Bahasa Melayu'},
    'sw': {'name': 'Swahili', 'native': 'Kiswahili'},
    'zu': {'name': 'Zulu', 'native': 'isiZulu'},
    'af': {'name': 'Afrikaans', 'native': 'Afrikaans'},
    'yo': {'name': 'Yoruba', 'native': 'Yorùbá'},
    'ig': {'name': 'Igbo', 'native': 'Igbo'},
    'ha': {'name': 'Hausa', 'native': 'Hausa'},
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final currentLang = await _storage.getLanguage();
    setState(() {
      _selectedLanguage = currentLang;
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    await _storage.saveLanguage(languageCode);
    setState(() {
      _selectedLanguage = languageCode;
    });
    if (widget.onLocaleChanged != null) {
      widget.onLocaleChanged!(languageCode);
    }
    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language changed to ${_languages[languageCode]?['native']}'),
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final languageCode = _languages.keys.elementAt(index);
          final language = _languages[languageCode]!;
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
                language['native']!,
                style: AppTextStyles.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                language['name']!,
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
      ),
    );
  }
} 