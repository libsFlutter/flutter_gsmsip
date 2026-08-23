import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tooltip для помощи по Dongle
class DongleHelpTooltip extends StatelessWidget {
  final String content;
  final Widget child;

  const DongleHelpTooltip({
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

/// Кнопка помощи для Dongle экранов
class DongleHelpButton extends StatelessWidget {
  final String title;
  final String content;

  const DongleHelpButton({
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

/// Экран справки по Dongle
class DongleHelpScreen extends StatelessWidget {
  const DongleHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dongle Help'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareHelp(context),
          ),
        ],
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadHelpContent(),
                    child: const Text('Retry'),
                  ),
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
    try {
      return await rootBundle.loadString('assets/help/dongle_guide.md');
    } catch (e) {
      // Return simplified help if file not found
      return '''
# Dongle Help

## Dongle Types

1. **USB-C with DAC** - Best quality, external DAC chip
2. **USB-C Audio Accessory** - Uses device DAC, analog
3. **TRRS 3.5mm** - Headset jack connection

## Quick Start

1. Connect your dongle
2. System auto-detects interface
3. Measure resistance for type detection
4. Configure settings
5. Test connection

## Troubleshooting

- **Not detected?** Check physical connection
- **Can't measure?** Normal for USB-C with DAC
- **Unknown type?** Select manually

For detailed help, visit:
https://gostsimbox.one/docs/dongles
''';
    }
  }

  void _shareHelp(BuildContext context) {
    // Share help content
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help sharing coming soon')),
    );
  }
}

/// Быстрый совет для Dongle
class DongleQuickTip extends StatelessWidget {
  final String tip;

  const DongleQuickTip({
    super.key,
    required this.tip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
