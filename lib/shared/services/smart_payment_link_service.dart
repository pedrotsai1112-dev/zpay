import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/payment_link_data.dart';
import '../models/result.dart';
import '../../core/constants/app_constants.dart';
import '../utils/taiwan_validators.dart';

/// 智慧清償連結服務
///
/// 負責生成和解析台灣金融環境的各種付款連結：
/// - TWQR (台灣QR共通標準)
/// - 銀行 Deep Link
/// - 門號轉帳
class SmartPaymentLinkService {
  static const String _baseUrl = 'https://zpay.tw/p';
  // static const String _apiVersion = 'v1'; // 暫時保留，未來版本管理使用

  /// 生成智慧清償連結
  Future<Result<SmartPaymentLink>> generateSmartLink(
    PaymentLinkData paymentData,
  ) async {
    try {
      // 驗證輸入數據
      final validationResult = _validatePaymentData(paymentData);
      if (validationResult.isFailure) {
        return Result.failure(validationResult.error ?? '驗證失敗');
      }

      // 根據付款類型生成不同的連結
      switch (paymentData.type) {
        case PaymentType.twqr:
          return await _generateTwqrLink(paymentData);
        case PaymentType.bankDeepLink:
          return await _generateBankDeepLink(paymentData);
        case PaymentType.phoneTransfer:
          return await _generatePhoneTransferLink(paymentData);
      }
    } catch (e) {
      return Result.failure('生成連結失敗: $e');
    }
  }

  /// 解析智慧清償連結
  Future<Result<PaymentLinkData>> parseSmartLink(String link) async {
    try {
      final uri = Uri.tryParse(link);
      if (uri == null) {
        return Result.failure('無效的連結格式');
      }

      // 檢查是否為 ZPay 短連結
      if (!uri.host.contains('zpay.tw')) {
        return Result.failure('無效的連結格式');
      }

      final params = uri.queryParameters;

      // 解析付款類型
      final typeStr = params['type'];
      if (typeStr == null) {
        return Result.failure('連結缺少付款類型信息');
      }

      PaymentType type;
      try {
        type = PaymentType.values.firstWhere((e) => e.name == typeStr);
      } catch (e) {
        // 處理舊的 type 值
        switch (typeStr) {
          case 'bank':
            type = PaymentType.bankDeepLink;
            break;
          case 'phone':
            type = PaymentType.phoneTransfer;
            break;
          default:
            return Result.failure('未知的付款類型: $typeStr');
        }
      }

      // 解析基本信息
      final amount = double.tryParse(params['amount'] ?? '0');
      if (amount == null || amount <= 0) {
        return Result.failure('無效的金額');
      }

      final currency = params['currency'] ?? 'TWD';

      // 根據付款類型解析收款人
      String recipient;
      String? bankCode;
      String? phoneNumber;

      switch (type) {
        case PaymentType.bankDeepLink:
          recipient = params['account'] ?? '';
          bankCode = params['bankCode'];
          break;
        case PaymentType.phoneTransfer:
          recipient = params['phone'] ?? '';
          phoneNumber = params['phone'];
          break;
        case PaymentType.twqr:
          recipient = params['recipient'] ?? '';
          break;
      }

      final memo = params['memo'] ?? '';
      final ttlSeconds = int.tryParse(params['ttl'] ?? '300') ?? 300;
      final createdAtStr = params['created'];

      DateTime createdAt = DateTime.now();
      if (createdAtStr != null) {
        createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();
      }

      // 創建付款數據
      final paymentData = PaymentLinkData(
        type: type,
        amount: amount,
        currency: currency,
        recipient: recipient,
        memo: memo,
        ttlSeconds: ttlSeconds,
        createdAt: createdAt,
        bankCode: bankCode,
        phoneNumber: phoneNumber,
      );

      // 檢查是否過期
      if (paymentData.isExpired) {
        return Result.failure('連結已過期');
      }

      return Result.success(paymentData);
    } catch (e) {
      return Result.failure('解析連結失敗: $e');
    }
  }

  /// 檢測可用的付款方式
  Future<List<PaymentMethod>> detectAvailablePaymentMethods() async {
    final methods = <PaymentMethod>[];

    // TWQR 始終可用（台灣QR共通標準）
    methods.add(
      const PaymentMethod(
        type: PaymentType.twqr,
        name: '台灣QR共通標準',
        scheme: 'twqr://',
        isAvailable: true,
        icon: '🏦',
      ),
    );

    // 檢測台灣主要銀行 App
    final banks = getSupportedBanks();
    for (final bank in banks) {
      final isInstalled = await _checkBankAppInstalled(bank.scheme);
      methods.add(
        PaymentMethod(
          type: PaymentType.bankDeepLink,
          name: bank.name,
          scheme: bank.scheme,
          isAvailable: isInstalled,
          reason: isInstalled ? null : '尚未安裝 ${bank.name} App',
          icon: bank.icon,
          bankCode: bank.code,
        ),
      );
    }

    // 門號轉帳始終可用
    methods.add(
      const PaymentMethod(
        type: PaymentType.phoneTransfer,
        name: '門號轉帳',
        scheme: 'phone-transfer://',
        isAvailable: true,
        icon: '📱',
      ),
    );

    return methods;
  }

  /// 獲取支援的台灣銀行列表
  List<TaiwanBank> getSupportedBanks() {
    return [
      const TaiwanBank(
        code: '004',
        name: '台灣銀行',
        scheme: 'bot-mobile://',
        icon: '🏛️',
        isSupported: true,
      ),
      const TaiwanBank(
        code: '005',
        name: '土地銀行',
        scheme: 'landbank://',
        icon: '🏞️',
        isSupported: true,
      ),
      const TaiwanBank(
        code: '006',
        name: '合作金庫',
        scheme: 'ccb-mobile://',
        icon: '🤝',
        isSupported: true,
      ),
      const TaiwanBank(
        code: '007',
        name: '第一銀行',
        scheme: 'firstbank://',
        icon: '🥇',
        isSupported: true,
      ),
      const TaiwanBank(
        code: '008',
        name: '華南銀行',
        scheme: 'hncb-mobile://',
        icon: '🌺',
        isSupported: true,
      ),
      const TaiwanBank(
        code: '009',
        name: '彰化銀行',
        scheme: 'chb-mobile://',
        icon: '🏪',
        isSupported: true,
      ),
      const TaiwanBank(
        code: '011',
        name: '上海商銀',
        scheme: 'scsb-mobile://',
        icon: '🏙️',
        isSupported: true,
      ),
      const TaiwanBank(
        code: '012',
        name: '台北富邦',
        scheme: 'fubon-bank://',
        icon: '💰',
        isSupported: true,
      ),
      const TaiwanBank(
        code: '013',
        name: '國泰世華',
        scheme: 'cathaybank://',
        icon: '🏦',
        isSupported: true,
      ),
      const TaiwanBank(
        code: '017',
        name: '兆豐銀行',
        scheme: 'megabank://',
        icon: '⭐',
        isSupported: true,
      ),
    ];
  }

  /// 生成銀行 Deep Link
  String generateBankDeepLink({
    required String bankCode,
    required double amount,
    required String account,
    required String memo,
  }) {
    final bank = getSupportedBanks().firstWhere(
      (b) => b.code == bankCode,
      orElse: () => throw ArgumentError('不支援的銀行代碼: $bankCode'),
    );

    // 根據不同銀行生成相應的 Deep Link 格式
    switch (bankCode) {
      case '012': // 台北富邦
        return '${bank.scheme}transfer?amount=${amount.toStringAsFixed(0)}&account=$account&memo=${Uri.encodeComponent(memo)}';
      case '013': // 國泰世華
        return '${bank.scheme}transfer?amount=${amount.toStringAsFixed(0)}&account=$account&memo=${Uri.encodeComponent(memo)}';
      case '017': // 兆豐銀行
        return '${bank.scheme}transfer?amount=${amount.toStringAsFixed(0)}&account=$account&memo=${Uri.encodeComponent(memo)}';
      default:
        // 通用格式
        return '${bank.scheme}transfer?amount=${amount.toStringAsFixed(0)}&account=$account&memo=${Uri.encodeComponent(memo)}';
    }
  }

  /// 驗證付款數據
  Result<void> _validatePaymentData(PaymentLinkData data) {
    // 先檢查金額
    if (data.amount <= 0) {
      return Result.failure('金額必須大於零');
    }

    if (!TaiwanValidators.isValidTransferAmount(data.amount)) {
      return Result.failure(
        '金額必須在 ${AppConstants.minTransferAmount} 到 ${AppConstants.maxTransferAmount} 之間',
      );
    }

    if (data.ttlSeconds <= 0) {
      return Result.failure('TTL必須大於零');
    }

    if (data.currency != 'TWD') {
      return Result.failure('目前僅支援新台幣 (TWD)');
    }

    if (data.recipient.isEmpty) {
      return Result.failure('收款人不能為空');
    }

    // 根據付款類型進行額外驗證
    switch (data.type) {
      case PaymentType.bankDeepLink:
        if (data.bankCode == null || data.bankCode!.isEmpty) {
          return Result.failure('銀行代碼不能為空');
        }
        if (!TaiwanValidators.isValidBankCode(data.bankCode!)) {
          return Result.failure('無效的銀行代碼');
        }
        break;
      case PaymentType.phoneTransfer:
        if (!TaiwanValidators.isValidTaiwanMobile(data.recipient)) {
          return Result.failure('無效的台灣手機號碼格式');
        }
        break;
      case PaymentType.twqr:
        // TWQR 目前不需要額外驗證
        break;
    }

    return Result.success(null);
  }

  /// 生成 TWQR 連結
  Future<Result<SmartPaymentLink>> _generateTwqrLink(
    PaymentLinkData data,
  ) async {
    final linkId = _generateLinkId();

    // 生成 TWQR 標準 URL
    final twqrUrl = _buildTwqrUrl(data);

    // 生成短連結
    final uri = Uri.parse('$_baseUrl/$linkId').replace(
      queryParameters: {
        'type': 'twqr',
        'amount': data.amount.toString(),
        'currency': data.currency,
        'recipient': data.recipient,
        'memo': data.memo,
        'ttl': data.ttlSeconds.toString(),
        'created': data.createdAt.toIso8601String(),
      },
    );
    final shortUrl = uri.toString();

    return Result.success(
      SmartPaymentLink(
        url: twqrUrl,
        deepLinkUrl: twqrUrl,
        shortUrl: shortUrl,
        type: PaymentType.twqr,
        createdAt: data.createdAt,
        ttlSeconds: data.ttlSeconds,
      ),
    );
  }

  /// 生成銀行 Deep Link
  Future<Result<SmartPaymentLink>> _generateBankDeepLink(
    PaymentLinkData data,
  ) async {
    if (data.bankCode == null) {
      return Result.failure('銀行代碼不能為空');
    }

    final bank = getSupportedBanks().firstWhere(
      (b) => b.code == data.bankCode,
      orElse: () => throw ArgumentError('不支援的銀行: ${data.bankCode}'),
    );

    final linkId = _generateLinkId();
    final deepLink = generateBankDeepLink(
      bankCode: data.bankCode!,
      amount: data.amount,
      account: data.recipient,
      memo: data.memo,
    );

    final uri = Uri.parse('$_baseUrl/$linkId').replace(
      queryParameters: {
        'type': 'bank',
        'bankCode': data.bankCode!,
        'amount': data.amount.toString(),
        'account': data.recipient,
        'memo': data.memo,
        'ttl': data.ttlSeconds.toString(),
        'created': data.createdAt.toIso8601String(),
      },
    );
    final shortUrl = uri.toString();

    return Result.success(
      SmartPaymentLink(
        url: deepLink,
        deepLinkUrl: deepLink,
        shortUrl: shortUrl,
        type: PaymentType.bankDeepLink,
        bankName: bank.name,
        createdAt: data.createdAt,
        ttlSeconds: data.ttlSeconds,
      ),
    );
  }

  /// 生成門號轉帳連結
  Future<Result<SmartPaymentLink>> _generatePhoneTransferLink(
    PaymentLinkData data,
  ) async {
    if (!TaiwanValidators.isValidTaiwanMobile(data.recipient)) {
      return Result.failure('無效的台灣手機號碼格式');
    }

    final linkId = _generateLinkId();
    final phoneUrl =
        'phone-transfer://transfer?phone=${data.recipient}&amount=${data.amount}&memo=${Uri.encodeComponent(data.memo)}';
    final copyText =
        '轉帳給 ${data.recipient}\n金額: NT\$ ${data.amount.toStringAsFixed(0)}\n備註: ${data.memo}';

    final uri = Uri.parse('$_baseUrl/$linkId').replace(
      queryParameters: {
        'type': 'phone',
        'phone': data.recipient,
        'amount': data.amount.toString(),
        'memo': data.memo,
        'ttl': data.ttlSeconds.toString(),
        'created': data.createdAt.toIso8601String(),
      },
    );
    final shortUrl = uri.toString();

    return Result.success(
      SmartPaymentLink(
        url: phoneUrl,
        deepLinkUrl: phoneUrl,
        shortUrl: shortUrl,
        type: PaymentType.phoneTransfer,
        phoneNumber: data.recipient,
        copyText: copyText,
        createdAt: data.createdAt,
        ttlSeconds: data.ttlSeconds,
      ),
    );
  }

  /// 建構 TWQR 標準 URL
  String _buildTwqrUrl(PaymentLinkData data) {
    final params = <String, String>{
      'amount': data.amount.toStringAsFixed(2),
      'currency': data.currency,
      'recipient': data.recipient,
      'memo': data.memo,
      'ttl': data.ttlSeconds.toString(),
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'twqr://payment?$queryString';
  }

  /// 生成唯一連結 ID
  String _generateLinkId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = Random().nextInt(999999).toString().padLeft(6, '0');
    final combined = '$timestamp$random';

    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);

    return digest.toString().substring(0, 12);
  }

  /// 檢查銀行 App 是否已安裝
  Future<bool> _checkBankAppInstalled(String scheme) async {
    try {
      return await canLaunchUrl(Uri.parse(scheme));
    } catch (e) {
      // 在測試環境或模擬器中，大部分銀行 App 都不會安裝
      return false;
    }
  }
}
