// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zpay_app/main.dart';

void main() {
  testWidgets('ZPay app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ZPayApp()));

    // Verify that the main navigation tabs are present
    expect(find.text('轉帳'), findsOneWidget);
    expect(find.text('分帳'), findsOneWidget);
    expect(find.text('好友'), findsOneWidget);

    // Verify that we start on the Pay page
    expect(find.text('轉帳/收款'), findsOneWidget);
    expect(find.text('金額'), findsOneWidget);

    // Test navigation to Split page
    await tester.tap(find.text('分帳'));
    await tester.pump();
    expect(find.text('分帳'), findsWidgets);

    // Test navigation to Friends page
    await tester.tap(find.text('好友'));
    await tester.pump();
    expect(find.text('好友'), findsWidgets);
  });
}
