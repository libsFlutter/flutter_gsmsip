import 'package:flutter/material.dart';

/// Tooltip для помощи по Voice Line
class VoiceLineHelpTooltip extends StatelessWidget {
  final String content;
  final Widget child;

  const VoiceLineHelpTooltip({
    super.key,
    required this.content,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: content,
      child: child,
    );
  }
}

/// Кнопка помощи для Voice Line экранов
class VoiceLineHelpButton extends StatelessWidget {
  final String title;
  final String content;

  const VoiceLineHelpButton({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline),
      onPressed: () => _showHelpDialog(context),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(content),
            ],
          ),
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
}

/// Экран справки по Voice Line
class VoiceLineHelpScreen extends StatelessWidget {
  const VoiceLineHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Line Help'),
      ),
      body: FutureBuilder<String>(
        future: _loadHelpContent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: 16),
                  Text('Error loading help: ${snapshot.error}'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              snapshot.data ?? 'No content available',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          );
        },
      ),
    );
  }

  Future<String> _loadHelpContent() async {
    // В реальной реализации - загрузка из assets/help/voice_line_methods.md
    return '''
Voice Line Methods Help

Available Methods:
1. TTY Port - Best quality, device-specific
2. Enhanced Mode - System-level access
3. Dongle - External hardware adapter
4. Telecom API - Standard Android API
5. Acoustic - Fallback option

For detailed help, visit:
https://gostsimbox.one/docs/voice-line
''';
  }
}
