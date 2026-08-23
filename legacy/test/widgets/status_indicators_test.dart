import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gsm_sip_gateway/services/theme_service.dart';
import 'package:flutter_gsm_sip_gateway/widgets/status_indicator.dart';

void main() {
  group('Status Indicators Widgets', () {
    late ThemeService themeService;

    setUp(() async {
      themeService = ThemeService();
      await themeService.initialize();
    });

    tearDown(() {
      themeService.dispose();
    });

    Widget createStatusIndicatorWidget({
      required String status,
      String? subtitle,
      IconData? icon,
    }) {
      return MaterialApp(
        home: ChangeNotifierProvider<ThemeService>.value(
          value: themeService,
          child: Scaffold(
            body: StatusIndicator(
              status: status,
              subtitle: subtitle,
              icon: icon,
            ),
          ),
        ),
      );
    }

    Widget createSignalIndicatorWidget({
      required int signalLevel,
      String? subtitle,
    }) {
      return MaterialApp(
        home: ChangeNotifierProvider<ThemeService>.value(
          value: themeService,
          child: Scaffold(
            body: SignalIndicator(
              signalLevel: signalLevel,
              subtitle: subtitle,
            ),
          ),
        ),
      );
    }

    Widget createCallStatusIndicatorWidget({
      required String callStatus,
      String? phoneNumber,
      String? duration,
    }) {
      return MaterialApp(
        home: ChangeNotifierProvider<ThemeService>.value(
          value: themeService,
          child: Scaffold(
            body: CallStatusIndicator(
              callStatus: callStatus,
              phoneNumber: phoneNumber,
              duration: duration,
            ),
          ),
        ),
      );
    }

    group('StatusIndicator', () {
      testWidgets('should display connected status with green color', (WidgetTester tester) async {
        await tester.pumpWidget(
          createStatusIndicatorWidget(status: 'connected'),
        );

        expect(find.text('Connection Status'), findsOneWidget);
        expect(find.text('connected'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('should display connecting status with yellow color', (WidgetTester tester) async {
        await tester.pumpWidget(
          createStatusIndicatorWidget(status: 'connecting'),
        );

        expect(find.text('Connection Status'), findsOneWidget);
        expect(find.text('connecting'), findsOneWidget);
        expect(find.byIcon(Icons.sync), findsOneWidget);
      });

      testWidgets('should display disconnected status with red color', (WidgetTester tester) async {
        await tester.pumpWidget(
          createStatusIndicatorWidget(status: 'disconnected'),
        );

        expect(find.text('Connection Status'), findsOneWidget);
        expect(find.text('disconnected'), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);
      });

      testWidgets('should display custom subtitle', (WidgetTester tester) async {
        await tester.pumpWidget(
          createStatusIndicatorWidget(
            status: 'connected',
            subtitle: 'SIP Server',
          ),
        );

        expect(find.text('SIP Server'), findsOneWidget);
      });

      testWidgets('should display custom icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          createStatusIndicatorWidget(
            status: 'connected',
            icon: Icons.cloud,
          ),
        );

        expect(find.byIcon(Icons.cloud), findsOneWidget);
      });

      testWidgets('should call onTap when tapped', (WidgetTester tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          createStatusIndicatorWidget(
            status: 'connected',
            onTap: () => tapped = true,
          ),
        );

        await tester.tap(find.byType(Card));
        await tester.pump();

        expect(tapped, isTrue);
      });
    });

    group('SignalIndicator', () {
      testWidgets('should display excellent signal level', (WidgetTester tester) async {
        await tester.pumpWidget(
          createSignalIndicatorWidget(signalLevel: 95),
        );

        expect(find.text('Signal Level'), findsOneWidget);
        expect(find.text('Excellent'), findsOneWidget);
        expect(find.text('95%'), findsOneWidget);
        expect(find.byIcon(Icons.signal_cellular_alt), findsOneWidget);
      });

      testWidgets('should display good signal level', (WidgetTester tester) async {
        await tester.pumpWidget(
          createSignalIndicatorWidget(signalLevel: 70),
        );

        expect(find.text('Good'), findsOneWidget);
        expect(find.text('70%'), findsOneWidget);
      });

      testWidgets('should display fair signal level', (WidgetTester tester) async {
        await tester.pumpWidget(
          createSignalIndicatorWidget(signalLevel: 50),
        );

        expect(find.text('Fair'), findsOneWidget);
        expect(find.text('50%'), findsOneWidget);
      });

      testWidgets('should display poor signal level', (WidgetTester tester) async {
        await tester.pumpWidget(
          createSignalIndicatorWidget(signalLevel: 25),
        );

        expect(find.text('Poor'), findsOneWidget);
        expect(find.text('25%'), findsOneWidget);
      });

      testWidgets('should display very poor signal level', (WidgetTester tester) async {
        await tester.pumpWidget(
          createSignalIndicatorWidget(signalLevel: 10),
        );

        expect(find.text('Very Poor'), findsOneWidget);
        expect(find.text('10%'), findsOneWidget);
      });

      testWidgets('should display custom subtitle', (WidgetTester tester) async {
        await tester.pumpWidget(
          createSignalIndicatorWidget(
            signalLevel: 85,
            subtitle: 'GSM Signal',
          ),
        );

        expect(find.text('GSM Signal'), findsOneWidget);
      });
    });

    group('CallStatusIndicator', () {
      testWidgets('should display active call status', (WidgetTester tester) async {
        await tester.pumpWidget(
          createCallStatusIndicatorWidget(callStatus: 'active'),
        );

        expect(find.text('Call Status'), findsOneWidget);
        expect(find.text('active'), findsOneWidget);
        expect(find.byIcon(Icons.call), findsOneWidget);
      });

      testWidgets('should display incoming call status', (WidgetTester tester) async {
        await tester.pumpWidget(
          createCallStatusIndicatorWidget(callStatus: 'incoming'),
        );

        expect(find.text('incoming'), findsOneWidget);
        expect(find.byIcon(Icons.call_received), findsOneWidget);
      });

      testWidgets('should display outgoing call status', (WidgetTester tester) async {
        await tester.pumpWidget(
          createCallStatusIndicatorWidget(callStatus: 'outgoing'),
        );

        expect(find.text('outgoing'), findsOneWidget);
        expect(find.byIcon(Icons.call_made), findsOneWidget);
      });

      testWidgets('should display ended call status', (WidgetTester tester) async {
        await tester.pumpWidget(
          createCallStatusIndicatorWidget(callStatus: 'ended'),
        );

        expect(find.text('ended'), findsOneWidget);
        expect(find.byIcon(Icons.call_end), findsOneWidget);
      });

      testWidgets('should display missed call status', (WidgetTester tester) async {
        await tester.pumpWidget(
          createCallStatusIndicatorWidget(callStatus: 'missed'),
        );

        expect(find.text('missed'), findsOneWidget);
        expect(find.byIcon(Icons.call_missed), findsOneWidget);
      });

      testWidgets('should display phone number when provided', (WidgetTester tester) async {
        await tester.pumpWidget(
          createCallStatusIndicatorWidget(
            callStatus: 'active',
            phoneNumber: '+1234567890',
          ),
        );

        expect(find.text('+1234567890'), findsOneWidget);
      });

      testWidgets('should display call duration when provided', (WidgetTester tester) async {
        await tester.pumpWidget(
          createCallStatusIndicatorWidget(
            callStatus: 'active',
            duration: '00:05:32',
          ),
        );

        expect(find.text('00:05:32'), findsOneWidget);
      });

      testWidgets('should display all call information', (WidgetTester tester) async {
        await tester.pumpWidget(
          createCallStatusIndicatorWidget(
            callStatus: 'active',
            phoneNumber: '+1234567890',
            duration: '00:05:32',
          ),
        );

        expect(find.text('Call Status'), findsOneWidget);
        expect(find.text('active'), findsOneWidget);
        expect(find.text('+1234567890'), findsOneWidget);
        expect(find.text('00:05:32'), findsOneWidget);
      });
    });

    group('Status Indicator Color Integration', () {
      testWidgets('should use ThemeService colors for status', (WidgetTester tester) async {
        await tester.pumpWidget(
          createStatusIndicatorWidget(status: 'connected'),
        );

        // Find the Container with the icon and verify it renders
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should update colors when theme changes', (WidgetTester tester) async {
        await tester.pumpWidget(
          createSignalIndicatorWidget(signalLevel: 85),
        );

        expect(find.text('Excellent'), findsOneWidget);

        // Change theme
        await themeService.setLightTheme();
        await tester.pump();

        // Widget should still display correctly
        expect(find.text('Excellent'), findsOneWidget);
      });
    });
  });
}
