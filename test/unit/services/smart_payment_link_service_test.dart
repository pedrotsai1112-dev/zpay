import 'package:flutter_test/flutter_test.dart';
import 'package:zpay_app/shared/services/smart_payment_link_service.dart';
import 'package:zpay_app/shared/models/payment_link_data.dart';

void main() {
  group('SmartPaymentLinkService', () {
    late SmartPaymentLinkService service;

    setUp(() {
      service = SmartPaymentLinkService();
    });

    group('generateSmartLink', () {
      test('should generate TWQR link for standard payment', () async {
        // Given
        final paymentData = PaymentLinkData(
          type: PaymentType.twqr,
          amount: 100.0,
          currency: 'TWD',
          recipient: '@alice',
          memo: '測試付款',
          ttlSeconds: 300,
        );

        // When
        final result = await service.generateSmartLink(paymentData);

        // Then
        expect(result.isSuccess, isTrue);
        final link = result.value!;
        expect(link.url, contains('twqr://'));
        expect(link.url, contains('amount=100.0'));
        expect(link.url, contains('currency=TWD'));
        expect(link.deepLinkUrl, isNotEmpty);
        expect(link.shortUrl, isNotEmpty);
      });

      test('should generate bank deep link for specific bank', () async {
        // Given
        final paymentData = PaymentLinkData(
          type: PaymentType.bankDeepLink,
          amount: 500.0,
          currency: 'TWD',
          recipient: '0123456789',
          bankCode: '012', // 台北富邦
          memo: 'KTV分帳',
          ttlSeconds: 300,
        );

        // When
        final result = await service.generateSmartLink(paymentData);

        // Then
        expect(result.isSuccess, isTrue);
        final link = result.value!;
        expect(link.url, contains('fubon-bank://'));
        expect(link.bankName, equals('台北富邦'));
        expect(link.deepLinkUrl, contains('transfer'));
      });

      test('should generate phone transfer link', () async {
        // Given
        final paymentData = PaymentLinkData(
          type: PaymentType.phoneTransfer,
          amount: 200.0,
          currency: 'TWD',
          recipient: '0912345678',
          memo: '午餐分帳',
          ttlSeconds: 300,
        );

        // When
        final result = await service.generateSmartLink(paymentData);

        // Then
        expect(result.isSuccess, isTrue);
        final link = result.value!;
        expect(link.phoneNumber, equals('0912345678'));
        expect(link.url, contains('phone-transfer://'));
        expect(link.copyText, isNotEmpty);
      });

      test('should fail for invalid amount', () async {
        // Given
        final paymentData = PaymentLinkData(
          type: PaymentType.twqr,
          amount: -50.0, // 無效金額
          currency: 'TWD',
          recipient: '@bob',
          memo: '測試',
          ttlSeconds: 300,
        );

        // When
        final result = await service.generateSmartLink(paymentData);

        // Then
        expect(result.isFailure, isTrue);
        expect(result.error, contains('金額必須大於'));
      });

      test('should fail for invalid TTL', () async {
        // Given
        final paymentData = PaymentLinkData(
          type: PaymentType.twqr,
          amount: 100.0,
          currency: 'TWD',
          recipient: '@charlie',
          memo: '測試',
          ttlSeconds: 0, // 無效TTL
        );

        // When
        final result = await service.generateSmartLink(paymentData);

        // Then
        expect(result.isFailure, isTrue);
        expect(result.error, contains('TTL必須大於零'));
      });
    });

    group('parseSmartLink', () {
      test('should parse TWQR link correctly', () async {
        // Given
        const smartLink =
            'https://zpay.tw/p/abc123?type=twqr&amount=100&currency=TWD&recipient=%40alice&memo=%E6%B8%AC%E8%A9%A6';

        // When
        final result = await service.parseSmartLink(smartLink);

        // Then
        expect(result.isSuccess, isTrue);
        final data = result.value!;
        expect(data.type, equals(PaymentType.twqr));
        expect(data.amount, equals(100.0));
        expect(data.currency, equals('TWD'));
        expect(data.recipient, equals('@alice'));
        expect(data.memo, equals('測試'));
      });

      test('should parse bank deep link correctly', () async {
        // Given
        const smartLink =
            'https://zpay.tw/p/def456?type=bank&bankCode=013&amount=500&account=1234567890&memo=KTV%E5%88%86%E5%B8%B3';

        // When
        final result = await service.parseSmartLink(smartLink);

        // Then
        expect(result.isSuccess, isTrue);
        final data = result.value!;
        expect(data.type, equals(PaymentType.bankDeepLink));
        expect(data.bankCode, equals('013'));
        expect(data.amount, equals(500.0));
        expect(data.recipient, equals('1234567890'));
      });

      test('should fail for invalid URL format', () async {
        // Given
        const invalidLink = 'not-a-valid-url';

        // When
        final result = await service.parseSmartLink(invalidLink);

        // Then
        expect(result.isFailure, isTrue);
        expect(result.error, contains('無效的連結格式'));
      });

      test('should fail for expired link', () async {
        // Given - 生成一個已過期的連結
        final expiredData = PaymentLinkData(
          type: PaymentType.twqr,
          amount: 100.0,
          currency: 'TWD',
          recipient: '@test',
          memo: '過期測試',
          ttlSeconds: 1, // 1秒TTL
          createdAt: DateTime.now().subtract(
            const Duration(seconds: 5),
          ), // 5秒前創建
        );

        final linkResult = await service.generateSmartLink(expiredData);
        final expiredLink = linkResult.value!.shortUrl;

        // When
        final result = await service.parseSmartLink(expiredLink);

        // Then
        expect(result.isFailure, isTrue);
        expect(result.error, contains('連結已過期'));
      });
    });

    group('detectAvailablePaymentMethods', () {
      test('should detect installed banking apps', () async {
        // When
        final methods = await service.detectAvailablePaymentMethods();

        // Then
        expect(methods, isA<List<PaymentMethod>>());
        expect(methods.isNotEmpty, isTrue);

        // 檢查是否包含 TWQR 作為預設選項
        final twqrMethod = methods.firstWhere(
          (m) => m.type == PaymentType.twqr,
          orElse: () => throw StateError('TWQR method not found'),
        );
        expect(twqrMethod.isAvailable, isTrue);
        expect(twqrMethod.name, equals('台灣QR共通標準'));
      });

      test('should mark unavailable methods correctly', () async {
        // When
        final methods = await service.detectAvailablePaymentMethods();

        // Then
        final unavailableMethods = methods
            .where((m) => !m.isAvailable)
            .toList();

        // 在測試環境中，大部分銀行App都應該是不可用的
        expect(unavailableMethods.isNotEmpty, isTrue);

        for (final method in unavailableMethods) {
          expect(method.isAvailable, isFalse);
          expect(method.reason, isNotEmpty);
        }
      });
    });

    group('Taiwan bank integration', () {
      test('should support major Taiwan banks', () {
        // Given
        final supportedBanks = service.getSupportedBanks();

        // Then
        expect(supportedBanks.length, greaterThanOrEqualTo(10));

        // 檢查主要銀行
        final bankCodes = supportedBanks.map((b) => b.code).toList();
        expect(bankCodes, contains('004')); // 台灣銀行
        expect(bankCodes, contains('012')); // 台北富邦
        expect(bankCodes, contains('013')); // 國泰世華
        expect(bankCodes, contains('017')); // 兆豐銀行
      });

      test('should generate correct deep link for each bank', () {
        // Given
        final banks = service.getSupportedBanks();

        for (final bank in banks.take(3)) {
          // 測試前3個銀行
          // When
          final deepLink = service.generateBankDeepLink(
            bankCode: bank.code,
            amount: 1000.0,
            account: '1234567890',
            memo: '測試轉帳',
          );

          // Then
          expect(deepLink, isNotEmpty);
          expect(deepLink, contains(bank.scheme));
          expect(deepLink, contains('1000'));
          expect(deepLink, contains('1234567890'));
        }
      });
    });
  });
}
