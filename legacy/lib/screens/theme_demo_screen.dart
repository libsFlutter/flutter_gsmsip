import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_widgets.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_gradients.dart';

/// Экран демонстрации всех возможностей темы
/// Показывает все компоненты и их поведение в светлой и темной темах
class ThemeDemoScreen extends StatelessWidget {
  const ThemeDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Demo'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            children: [
              // Цветовая палитра
              _buildSection(
                context,
                'Color Palette',
                _buildColorPalette(context),
              ),
              
              const SizedBox(height: AppDimensions.paddingXL),
              
              // Градиенты
              _buildSection(
                context,
                'Gradients',
                _buildGradients(context),
              ),
              
              const SizedBox(height: AppDimensions.paddingXL),
              
              // Кнопки
              _buildSection(
                context,
                'Buttons',
                _buildButtons(context),
              ),
              
              const SizedBox(height: AppDimensions.paddingXL),
              
              // Статусные индикаторы
              _buildSection(
                context,
                'Status Indicators',
                _buildStatusIndicators(context),
              ),
              
              const SizedBox(height: AppDimensions.paddingXL),
              
              // Карточки
              _buildSection(
                context,
                'Cards',
                _buildCards(context),
              ),
              
              const SizedBox(height: AppDimensions.paddingXL),
              
              // Прогресс-бары
              _buildSection(
                context,
                'Progress Indicators',
                _buildProgressIndicators(context),
              ),
              
              const SizedBox(height: AppDimensions.paddingXL),
              
              // Чипы
              _buildSection(
                context,
                'Chips',
                _buildChips(context),
              ),
              
              const SizedBox(height: AppDimensions.paddingXL),
              
              // Поля ввода
              _buildSection(
                context,
                'Input Fields',
                _buildInputFields(context),
              ),
              
              const SizedBox(height: AppDimensions.paddingXL),
              
              // Переключатели
              _buildSection(
                context,
                'Switches',
                _buildSwitches(context),
              ),
              
              const SizedBox(height: AppDimensions.paddingXL),
              
              // Слайдеры
              _buildSection(
                context,
                'Sliders',
                _buildSliders(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        content,
      ],
    );
  }

  Widget _buildColorPalette(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.paddingM,
      runSpacing: AppDimensions.paddingM,
      children: [
        _buildColorChip(context, 'Primary', AppColors.primary),
        _buildColorChip(context, 'Accent', AppColors.accent),
        _buildColorChip(context, 'Technical', AppColors.technical),
        _buildColorChip(context, 'Success', AppColors.success),
        _buildColorChip(context, 'Warning', AppColors.warning),
        _buildColorChip(context, 'Error', AppColors.error),
        _buildColorChip(context, 'Info', AppColors.info),
        _buildColorChip(context, 'Connected', AppColors.gatewayConnected),
        _buildColorChip(context, 'Disconnected', AppColors.gatewayDisconnected),
        _buildColorChip(context, 'Signal Strong', AppColors.signalStrong),
        _buildColorChip(context, 'Signal Weak', AppColors.signalWeak),
        _buildColorChip(context, 'Call Active', AppColors.callActive),
      ],
    );
  }

  Widget _buildColorChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradients(BuildContext context) {
    return Column(
      children: [
        _buildGradientCard(context, 'Primary', AppGradients.primaryGradient),
        const SizedBox(height: AppDimensions.paddingM),
        _buildGradientCard(context, 'Accent', AppGradients.accentGradient),
        const SizedBox(height: AppDimensions.paddingM),
        _buildGradientCard(context, 'Technical', AppGradients.technicalGradient),
        const SizedBox(height: AppDimensions.paddingM),
        _buildGradientCard(context, 'Connection', AppGradients.connectionGradient),
      ],
    );
  }

  Widget _buildGradientCard(BuildContext context, String label, LinearGradient gradient) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        gradient: gradient,
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        AppWidgets.gradientButton(
          text: 'Primary Button',
          onPressed: () {},
          icon: Icons.check,
        ),
        const SizedBox(height: AppDimensions.paddingM),
        AppWidgets.gradientButton(
          text: 'Secondary Button',
          onPressed: () {},
          colors: [AppColors.accent, AppColors.accentLight],
        ),
        const SizedBox(height: AppDimensions.paddingM),
        AppWidgets.gradientButton(
          text: 'Loading Button',
          onPressed: () {},
          isLoading: true,
        ),
        const SizedBox(height: AppDimensions.paddingM),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Standard Button'),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        TextButton(
          onPressed: () {},
          child: const Text('Text Button'),
        ),
      ],
    );
  }

  Widget _buildStatusIndicators(BuildContext context) {
    return Column(
      children: [
        AppWidgets.statusCard(
          title: 'Gateway Status',
          status: 'Connected',
          icon: Icons.wifi,
          statusColor: AppColors.gatewayConnected,
          subtitle: 'All systems operational',
        ),
        const SizedBox(height: AppDimensions.paddingM),
        AppWidgets.statusCard(
          title: 'Signal Level',
          status: 'Excellent',
          icon: Icons.signal_cellular_alt,
          statusColor: AppColors.signalStrong,
          subtitle: '85% strength',
        ),
        const SizedBox(height: AppDimensions.paddingM),
        AppWidgets.statusCard(
          title: 'Call Status',
          status: 'Active',
          icon: Icons.call,
          statusColor: AppColors.callActive,
          subtitle: 'Duration: 2:34',
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Row(
          children: [
            AppWidgets.connectionIndicator(
              status: 'Connected',
              showText: true,
            ),
            const SizedBox(width: AppDimensions.paddingL),
            AppWidgets.signalIndicator(
              signalLevel: 85,
              showBars: true,
              showPercentage: true,
            ),
            const SizedBox(width: AppDimensions.paddingL),
            AppWidgets.callStatusIndicator(
              status: 'Active',
              phoneNumber: '+1234567890',
              duration: '2:34',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCards(BuildContext context) {
    return Column(
      children: [
        AppWidgets.gradientCard(
          child: const Text('Gradient Card'),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.cardPadding),
            child: const Text('Standard Card'),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            gradient: AppGradients.cardGradient,
          ),
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          child: const Text('Custom Gradient Card'),
        ),
      ],
    );
  }

  Widget _buildProgressIndicators(BuildContext context) {
    return Column(
      children: [
        AppWidgets.gradientProgressIndicator(
          value: 0.75,
          label: 'Connection Progress',
        ),
        const SizedBox(height: AppDimensions.paddingM),
        AppWidgets.gradientProgressIndicator(
          value: 0.45,
          label: 'Signal Strength',
          colors: [AppColors.warning, const Color(0xFFFBBF24)],
        ),
        const SizedBox(height: AppDimensions.paddingM),
        AppWidgets.gradientProgressIndicator(
          value: 0.90,
          label: 'System Health',
          colors: [AppColors.success, const Color(0xFF34D399)],
        ),
        const SizedBox(height: AppDimensions.paddingM),
        LinearProgressIndicator(
          value: 0.6,
          backgroundColor: AppColors.progressBackground,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.progressFill),
        ),
      ],
    );
  }

  Widget _buildChips(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.paddingM,
      runSpacing: AppDimensions.paddingM,
      children: [
        AppWidgets.gradientChip(
          label: 'Connected',
          icon: Icons.check,
          isSelected: true,
        ),
        AppWidgets.gradientChip(
          label: 'Disconnected',
          icon: Icons.close,
        ),
        AppWidgets.gradientChip(
          label: 'Connecting',
          icon: Icons.sync,
        ),
        AppWidgets.gradientChip(
          label: 'Error',
          icon: Icons.error,
        ),
        AppWidgets.gradientChip(
          label: 'Warning',
          icon: Icons.warning,
        ),
        AppWidgets.gradientChip(
          label: 'Info',
          icon: Icons.info,
        ),
      ],
    );
  }

  Widget _buildInputFields(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Server Address',
            hintText: 'Enter server address',
            prefixIcon: Icon(Icons.computer),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Port Number',
            hintText: 'Enter port number',
            prefixIcon: Icon(Icons.numbers),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        TextField(
          decoration: const InputDecoration(
            labelText: 'API Key',
            hintText: 'Enter API key',
            prefixIcon: Icon(Icons.key),
            suffixIcon: Icon(Icons.visibility),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitches(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Auto Connect'),
          subtitle: const Text('Automatically connect on startup'),
          value: true,
          onChanged: (value) {},
        ),
        SwitchListTile(
          title: const Text('Notifications'),
          subtitle: const Text('Show system notifications'),
          value: false,
          onChanged: (value) {},
        ),
        SwitchListTile(
          title: const Text('Dark Theme'),
          subtitle: const Text('Use dark theme'),
          value: true,
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildSliders(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: 0.7,
          onChanged: (value) {},
          label: 'Volume',
        ),
        Slider(
          value: 0.3,
          onChanged: (value) {},
          label: 'Brightness',
        ),
        Slider(
          value: 0.8,
          onChanged: (value) {},
          label: 'Sensitivity',
        ),
      ],
    );
  }
} 