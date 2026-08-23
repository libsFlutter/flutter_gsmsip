import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gsm_sip_gateway/presentation/widgets/dashboard_widget.dart';
import 'package:flutter_gsm_sip_gateway/presentation/providers/dashboard_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'dashboard_widget_test.mocks.dart';

@GenerateMocks([DashboardProvider])
void main() {
  group('DashboardWidget', () {
    late MockDashboardProvider mockProvider;

    setUp(() {
      mockProvider = MockDashboardProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<DashboardProvider>.value(
          value: mockProvider,
          child: const DashboardWidget(),
        ),
      );
    }

    testWidgets('should display dashboard title', (WidgetTester tester) async {
      // arrange
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.error).thenReturn(null);

      // act
      await tester.pumpWidget(createTestWidget());

      // assert
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (WidgetTester tester) async {
      // arrange
      when(mockProvider.isLoading).thenReturn(true);
      when(mockProvider.error).thenReturn(null);

      // act
      await tester.pumpWidget(createTestWidget());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when error occurs', (WidgetTester tester) async {
      // arrange
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.error).thenReturn('Test error message');

      // act
      await tester.pumpWidget(createTestWidget());

      // assert
      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('should display statistics cards', (WidgetTester tester) async {
      // arrange
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.error).thenReturn(null);
      when(mockProvider.totalCalls).thenReturn(1500);
      when(mockProvider.totalSms).thenReturn(3200);
      when(mockProvider.activeSimCards).thenReturn(45);

      // act
      await tester.pumpWidget(createTestWidget());

      // assert
      expect(find.text('1500'), findsOneWidget);
      expect(find.text('3200'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
    });

    testWidgets('should call refresh when refresh button is pressed', (WidgetTester tester) async {
      // arrange
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.error).thenReturn(null);
      when(mockProvider.refresh()).thenAnswer((_) async {});

      // act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // assert
      verify(mockProvider.refresh()).called(1);
    });

    testWidgets('should display gateway status indicator', (WidgetTester tester) async {
      // arrange
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.error).thenReturn(null);
      when(mockProvider.gatewayStatus).thenReturn('Running');

      // act
      await tester.pumpWidget(createTestWidget());

      // assert
      expect(find.text('Running'), findsOneWidget);
    });

    testWidgets('should handle empty statistics gracefully', (WidgetTester tester) async {
      // arrange
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.error).thenReturn(null);
      when(mockProvider.totalCalls).thenReturn(0);
      when(mockProvider.totalSms).thenReturn(0);
      when(mockProvider.activeSimCards).thenReturn(0);

      // act
      await tester.pumpWidget(createTestWidget());

      // assert
      expect(find.text('0'), findsNWidgets(3));
    });
  });
}
