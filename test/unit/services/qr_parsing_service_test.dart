import 'package:flutter_test/flutter_test.dart';
import 'package:zpay_app/shared/services/qr_parsing_service.dart';
import 'package:zpay_app/shared/models/qr_data.dart';

void main() {
  group('QrParsingService Tests (TDD)', () {
    late QrParsingService service;

    setUp(() {
      service = QrParsingService();
    });

    group('ZPay 協議解析', () {
      test('應該正確解析完整的 ZPay 轉帳 QR Code', () {
        // Arrange
        const qrString = 'zpay://pay?to=@alice&amount=150&ttl=300&token=abc123&memo=coffee';

        // Act
        final result = service.parseQrCode(qrString);

        // Assert
        expect(result.isSuccess, isTrue);
        final qrData = result.data!;
        expect(qrData.type, equals(QrCodeType.payment));
        expect(qrData.recipient, equals('@alice'));
        expect(qrData.amount, equals(150.0));
        expect(qrData.ttl, equals(300));
        expect(qrData.token, equals('abc123'));
        expect(qrData.memo, equals('coffee'));
      });

      test('應該正確解析沒有金額的 QR Code', () {
        // Arrange
        const qrString = 'zpay://pay?to=@bob&ttl=600';

        // Act
        final result = service.parseQrCode(qrString);

        // Assert
        expect(result.isSuccess, isTrue);
        final qrData = result.data!;
        expect(qrData.type, equals(QrCodeType.payment));
        expect(qrData.recipient, equals('@bob'));
        expect(qrData.amount, isNull);
        expect(qrData.ttl, equals(600));
      });

      test('應該正確解析加好友 QR Code', () {
        // Arrange
        const qrString = 'zpay://friend?user=@charlie&nickname=Charlie&avatar=https://example.com/avatar.jpg';

        // Act
        final result = service.parseQrCode(qrString);

        // Assert
        expect(result.isSuccess, isTrue);
        final qrData = result.data!;
        expect(qrData.type, equals(QrCodeType.addFriend));
        expect(qrData.recipient, equals('@charlie'));
        expect(qrData.nickname, equals('Charlie'));
        expect(qrData.avatarUrl, equals('https://example.com/avatar.jpg'));
      });

      test('應該正確解析分帳邀請 QR Code', () {
        // Arrange
        const qrString = 'zpay://split?id=split123&title=晚餐&amount=600&participants=4&creator=@alice';

        // Act
        final result = service.parseQrCode(qrString);

        // Assert
        expect(result.isSuccess, isTrue);
        final qrData = result.data!;
        expect(qrData.type, equals(QrCodeType.splitInvite));
        expect(qrData.splitId, equals('split123'));
        expect(qrData.title, equals('晚餐'));
        expect(qrData.amount, equals(600.0));
        expect(qrData.participantCount, equals(4));
        expect(qrData.creator, equals('@alice'));
      });
    });

    group('外部 QR Code 處理', () {
      test('應該識別一般網址 QR Code', () {
        // Arrange
        const qrString = 'https://www.google.com';

        // Act
        final result = service.parseQrCode(qrString);

        // Assert
        expect(result.isSuccess, isTrue);
        final qrData = result.data!;
        expect(qrData.type, equals(QrCodeType.url));
        expect(qrData.url, equals(qrString));
      });

      test('應該識別純文字 QR Code', () {
        // Arrange
        const qrString = '這是一段純文字內容';

        // Act
        final result = service.parseQrCode(qrString);

        // Assert
        expect(result.isSuccess, isTrue);
        final qrData = result.data!;
        expect(qrData.type, equals(QrCodeType.text));
        expect(qrData.text, equals(qrString));
      });
    });

    group('錯誤處理', () {
      test('空字串應該返回錯誤', () {
        // Act
        final result = service.parseQrCode('');

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.error, contains('不能為空'));
      });

      test('格式錯誤的 ZPay 協議應該返回錯誤', () {
        // Act
        final result = service.parseQrCode('zpay://invalid');

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.error, contains('不支援'));
      });

      test('缺少必要參數的支付 QR 應該返回錯誤', () {
        // Act - 缺少 to 參數
        final result = service.parseQrCode('zpay://pay?amount=100');

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.error, contains('收款人'));
      });
    });

    group('QR Code 生成', () {
      test('應該正確生成支付 QR Code', () {
        // Arrange
        final qrData = QrData.payment(
          recipient: '@alice',
          amount: 100.0,
          ttl: 300,
          token: 'test123',
          memo: '測試付款',
        );

        // Act
        final result = service.generateQrString(qrData);

        // Assert
        expect(result, contains('zpay://pay'));
        expect(result, contains('to=%40alice')); // @ 會被編碼為 %40
        expect(result, contains('amount=100.0'));
        expect(result, contains('ttl=300'));
        expect(result, contains('token=test123'));
        // memo 會被 URL 編碼
      });

      test('應該正確生成加好友 QR Code', () {
        // Arrange
        final qrData = QrData.addFriend(
          user: '@bob',
          nickname: 'Bob',
          avatarUrl: 'https://example.com/bob.jpg',
        );

        // Act
        final result = service.generateQrString(qrData);

        // Assert
        expect(result, contains('zpay://friend'));
        expect(result, contains('user=%40bob')); // @ 會被編碼為 %40
        expect(result, contains('nickname=Bob'));
        // URL 會被編碼
      });
    });
  });
}
