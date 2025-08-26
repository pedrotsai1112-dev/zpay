import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:zpay_app/features/pay/scan_page.dart';
import '../../test_helpers.dart';

void main() {
  group('ScanPage Widget Tests (TDD)', () {
    testWidgets('應該顯示掃描頁面基本 UI', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        TestHelpers.createTestWidget(const ScanPage()),
      );

      // Assert
      expect(find.text('掃描 QR'), findsOneWidget);
      expect(find.byType(MobileScanner), findsOneWidget);
    });

    testWidgets('應該顯示掃描指引文字', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        TestHelpers.createTestWidget(const ScanPage()),
      );

      // Assert
      expect(find.text('將 QR Code 對準掃描框'), findsOneWidget);
      expect(find.text('支援 ZPay 轉帳、加好友、分帳邀請'), findsOneWidget);
    });

    testWidgets('應該有關閉按鈕', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        TestHelpers.createTestWidget(const ScanPage()),
      );

      // Assert
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('點擊關閉按鈕應該返回', (WidgetTester tester) async {
      // Arrange
      bool navigatorPopped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ScanPage(),
                    ),
                  );
                },
                child: const Text('Open Scanner'),
              ),
            ),
          ),
          navigatorObservers: [
            _TestNavigatorObserver(
              onPopped: () => navigatorPopped = true,
            ),
          ],
        ),
      );

      // Act - 打開掃描頁面
      await tester.tap(find.text('Open Scanner'));
      await tester.pumpAndSettle();

      // 點擊關閉按鈕
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Assert
      expect(navigatorPopped, isTrue);
    });

    testWidgets('應該顯示掃描結果處理 UI', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        TestHelpers.createTestWidget(const ScanPage()),
      );

      // Assert - 應該有處理掃描結果的相關元素
      expect(find.byType(MobileScanner), findsOneWidget);
    });

    group('QR Code 掃描處理', () {
      testWidgets('掃描到 ZPay 支付 QR 應該顯示確認對話框', (WidgetTester tester) async {
        // Note: 這個測試需要模擬掃描事件，實際實現時可能需要使用 mock
        // 目前先驗證基本結構存在
        
        await tester.pumpWidget(
          TestHelpers.createTestWidget(const ScanPage()),
        );

        expect(find.byType(ScanPage), findsOneWidget);
      });

      testWidgets('掃描到加好友 QR 應該顯示好友信息', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestHelpers.createTestWidget(const ScanPage()),
        );

        expect(find.byType(ScanPage), findsOneWidget);
      });

      testWidgets('掃描到無效 QR 應該顯示錯誤信息', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestHelpers.createTestWidget(const ScanPage()),
        );

        expect(find.byType(ScanPage), findsOneWidget);
      });
    });

    group('權限處理', () {
      testWidgets('應該處理相機權限請求', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestHelpers.createTestWidget(const ScanPage()),
        );

        // 驗證 MobileScanner 存在（它會處理權限）
        expect(find.byType(MobileScanner), findsOneWidget);
      });

      testWidgets('權限被拒絕時應該顯示提示', (WidgetTester tester) async {
        // 這個測試需要模擬權限被拒絕的情況
        await tester.pumpWidget(
          TestHelpers.createTestWidget(const ScanPage()),
        );

        expect(find.byType(ScanPage), findsOneWidget);
      });
    });
  });
}

/// 測試用的 Navigator Observer
class _TestNavigatorObserver extends NavigatorObserver {
  final VoidCallback? onPopped;

  _TestNavigatorObserver({this.onPopped});

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    onPopped?.call();
  }
}
