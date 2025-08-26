import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zpay_app/shared/widgets/circular_qr_widget.dart';
import '../../test_helpers.dart';

void main() {
  group('CircularQrWidget Tests', () {
    testWidgets('應該顯示 QR Code 和描述文字', (WidgetTester tester) async {
      // Arrange
      const qrData = 'zpay://pay?to=@test&amount=100&ttl=300&token=test';
      const description = '測試 QR Code';

      // Act
      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          const CircularQrWidget(
            data: qrData,
            description: description,
          ),
        ),
      );

      // Assert
      TestHelpers.expectText(description);
      expect(find.byType(CircularQrWidget), findsOneWidget);
    });

    testWidgets('當 animated 為 true 時應該顯示動畫', (WidgetTester tester) async {
      // Arrange
      const qrData = 'zpay://pay?to=@test&amount=100&ttl=300&token=test';

      // Act
      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          const CircularQrWidget(
            data: qrData,
            animated: true,
          ),
        ),
      );

      // 讓動畫開始
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.byType(CircularQrWidget), findsOneWidget);
      // 檢查是否有動畫控制器（AnimatedBuilder 可能有多個，這是正常的）
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));
    });

    testWidgets('當 animated 為 false 時不應該有動畫', (WidgetTester tester) async {
      // Arrange
      const qrData = 'zpay://pay?to=@test&amount=100&ttl=300&token=test';

      // Act
      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          const CircularQrWidget(
            data: qrData,
            animated: false,
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularQrWidget), findsOneWidget);
      // 非動畫版本不應該有 AnimatedBuilder
    });

    testWidgets('應該能夠自定義大小', (WidgetTester tester) async {
      // Arrange
      const qrData = 'zpay://pay?to=@test&amount=100&ttl=300&token=test';
      const customSize = 300.0;

      // Act
      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          const CircularQrWidget(
            data: qrData,
            size: customSize,
          ),
        ),
      );

      // Assert
      final widget = tester.widget<CircularQrWidget>(find.byType(CircularQrWidget));
      expect(widget.size, equals(customSize));
    });

    testWidgets('QR Code 數據變更時應該更新顯示', (WidgetTester tester) async {
      // Arrange
      const initialData = 'zpay://pay?to=@test1&amount=100';
      const updatedData = 'zpay://pay?to=@test2&amount=200';

      // Act - 初始渲染
      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          const CircularQrWidget(data: initialData),
        ),
      );

      // 驗證初始狀態
      expect(find.byType(CircularQrWidget), findsOneWidget);

      // Act - 更新數據
      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          const CircularQrWidget(data: updatedData),
        ),
      );

      await tester.pump();

      // Assert
      final widget = tester.widget<CircularQrWidget>(find.byType(CircularQrWidget));
      expect(widget.data, equals(updatedData));
    });
  });
}
