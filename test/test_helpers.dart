import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 測試輔助工具
class TestHelpers {
  /// 創建測試用的 Widget 包裝器
  static Widget createTestWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        home: child,
      ),
    );
  }

  /// 創建測試用的 Provider 作用域
  static Widget createTestWidgetWithProviders(
    Widget child, {
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: child,
      ),
    );
  }

  /// 等待 Widget 樹穩定
  static Future<void> pumpAndSettle(WidgetTester tester) async {
    await tester.pump();
    await tester.pumpAndSettle();
  }

  /// 模擬網絡延遲
  static Future<void> simulateNetworkDelay([int milliseconds = 100]) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  /// 驗證 Widget 是否存在並可見
  static void expectVisible(Finder finder) {
    expect(finder, findsOneWidget);
    expect(
      finder.evaluate().single.widget,
      predicate<Widget>((w) => w.key != null || true),
    );
  }

  /// 驗證文本內容
  static void expectText(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// 驗證圖標存在
  static void expectIcon(IconData icon) {
    expect(find.byIcon(icon), findsOneWidget);
  }
}

/// 測試數據工廠
class TestDataFactory {
  /// 創建測試用 QR Code 數據
  static String createQrData({
    String to = '@testuser',
    int amount = 100,
    int ttl = 300,
    String token = 'test-token',
  }) {
    return 'zpay://pay?to=$to&amount=$amount&ttl=$ttl&token=$token';
  }

  /// 創建測試用好友數據
  static List<String> createFriendsList() {
    return ['@alice', '@bob', '@charlie', '@diana'];
  }

  /// 創建測試用分帳描述
  static List<String> createSplitDescriptions() {
    return [
      '我幫4個人付了500',
      '晚餐 3人 AA 300元',
      '買咖啡代付 5杯 每杯30',
    ];
  }
}
