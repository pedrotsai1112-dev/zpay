import 'package:flutter_test/flutter_test.dart';
import 'package:zpay_app/shared/models/qr_data.dart';

void main() {
  group('QrData Model Tests (TDD)', () {
    group('支付 QR 數據', () {
      test('應該正確創建支付 QR 數據', () {
        // Act
        final qrData = QrData.payment(
          recipient: '@alice',
          amount: 150.0,
          ttl: 300,
          token: 'abc123',
          memo: 'coffee',
        );

        // Assert
        expect(qrData.type, equals(QrCodeType.payment));
        expect(qrData.recipient, equals('@alice'));
        expect(qrData.amount, equals(150.0));
        expect(qrData.ttl, equals(300));
        expect(qrData.token, equals('abc123'));
        expect(qrData.memo, equals('coffee'));
        expect(qrData.isExpired, isFalse);
      });

      test('應該正確計算 QR Code 是否過期', () {
        // Arrange
        final expiredQr = QrData.payment(
          recipient: '@test',
          ttl: 1, // 1秒有效期
          createdAt: DateTime.now().subtract(const Duration(seconds: 10)), // 10秒前創建
        );

        final validQr = QrData.payment(
          recipient: '@test',
          ttl: 300, // 5分鐘有效期
          createdAt: DateTime.now(),
        );

        // Assert
        expect(expiredQr.isExpired, isTrue);
        expect(validQr.isExpired, isFalse);
      });
    });

    group('好友 QR 數據', () {
      test('應該正確創建加好友 QR 數據', () {
        // Act
        final qrData = QrData.addFriend(
          user: '@bob',
          nickname: 'Bob Smith',
          avatarUrl: 'https://example.com/avatar.jpg',
        );

        // Assert
        expect(qrData.type, equals(QrCodeType.addFriend));
        expect(qrData.recipient, equals('@bob'));
        expect(qrData.nickname, equals('Bob Smith'));
        expect(qrData.avatarUrl, equals('https://example.com/avatar.jpg'));
      });
    });

    group('分帳 QR 數據', () {
      test('應該正確創建分帳邀請 QR 數據', () {
        // Act
        final qrData = QrData.splitInvite(
          splitId: 'split123',
          title: '晚餐分帳',
          amount: 600.0,
          participantCount: 4,
          creator: '@alice',
        );

        // Assert
        expect(qrData.type, equals(QrCodeType.splitInvite));
        expect(qrData.splitId, equals('split123'));
        expect(qrData.title, equals('晚餐分帳'));
        expect(qrData.amount, equals(600.0));
        expect(qrData.participantCount, equals(4));
        expect(qrData.creator, equals('@alice'));
      });
    });

    group('通用 QR 數據', () {
      test('應該正確創建網址 QR 數據', () {
        // Act
        final qrData = QrData.url('https://www.google.com');

        // Assert
        expect(qrData.type, equals(QrCodeType.url));
        expect(qrData.url, equals('https://www.google.com'));
      });

      test('應該正確創建文字 QR 數據', () {
        // Act
        final qrData = QrData.text('這是一段測試文字');

        // Assert
        expect(qrData.type, equals(QrCodeType.text));
        expect(qrData.text, equals('這是一段測試文字'));
      });
    });

    group('數據驗證', () {
      test('支付金額應該大於零', () {
        // Act & Assert
        expect(
          () => QrData.payment(recipient: '@test', amount: -10),
          throwsArgumentError,
        );
      });

      test('TTL 應該大於零', () {
        // Act & Assert
        expect(
          () => QrData.payment(recipient: '@test', ttl: -1),
          throwsArgumentError,
        );
      });

      test('收款人不能為空', () {
        // Act & Assert
        expect(
          () => QrData.payment(recipient: ''),
          throwsArgumentError,
        );
      });
    });
  });
}
