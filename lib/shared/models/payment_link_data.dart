/// 智慧清償連結的付款數據模型
class PaymentLinkData {
  final PaymentType type;
  final double amount;
  final String currency;
  final String recipient;
  final String memo;
  final int ttlSeconds;
  final DateTime createdAt;
  final String? bankCode;
  final String? phoneNumber;
  final Map<String, dynamic>? metadata;

  PaymentLinkData({
    required this.type,
    required this.amount,
    required this.currency,
    required this.recipient,
    required this.memo,
    required this.ttlSeconds,
    DateTime? createdAt,
    this.bankCode,
    this.phoneNumber,
    this.metadata,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 檢查連結是否已過期
  bool get isExpired {
    final expiryTime = createdAt.add(Duration(seconds: ttlSeconds));
    return DateTime.now().isAfter(expiryTime);
  }

  /// 剩餘有效時間（秒）
  int get remainingSeconds {
    if (isExpired) return 0;
    final expiryTime = createdAt.add(Duration(seconds: ttlSeconds));
    return expiryTime.difference(DateTime.now()).inSeconds;
  }

  /// 驗證付款數據
  bool get isValid {
    if (ttlSeconds <= 0) return false;
    if (recipient.isEmpty) return false;
    if (currency != 'TWD') return false;

    // 根據付款類型進行額外驗證
    switch (type) {
      case PaymentType.bankDeepLink:
        return bankCode != null && bankCode!.isNotEmpty;
      case PaymentType.phoneTransfer:
        return phoneNumber != null && phoneNumber!.isNotEmpty;
      case PaymentType.twqr:
        return true;
    }
  }

  /// 轉為 JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'amount': amount,
      'currency': currency,
      'recipient': recipient,
      'memo': memo,
      'ttlSeconds': ttlSeconds,
      'createdAt': createdAt.toIso8601String(),
      'bankCode': bankCode,
      'phoneNumber': phoneNumber,
      'metadata': metadata,
    };
  }

  /// 從 JSON 創建
  factory PaymentLinkData.fromJson(Map<String, dynamic> json) {
    return PaymentLinkData(
      type: PaymentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentType.twqr,
      ),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      recipient: json['recipient'] as String,
      memo: json['memo'] as String,
      ttlSeconds: json['ttlSeconds'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      bankCode: json['bankCode'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// 創建副本
  PaymentLinkData copyWith({
    PaymentType? type,
    double? amount,
    String? currency,
    String? recipient,
    String? memo,
    int? ttlSeconds,
    DateTime? createdAt,
    String? bankCode,
    String? phoneNumber,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentLinkData(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      recipient: recipient ?? this.recipient,
      memo: memo ?? this.memo,
      ttlSeconds: ttlSeconds ?? this.ttlSeconds,
      createdAt: createdAt ?? this.createdAt,
      bankCode: bankCode ?? this.bankCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'PaymentLinkData(type: $type, amount: $amount, recipient: $recipient, memo: $memo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentLinkData &&
        other.type == type &&
        other.amount == amount &&
        other.currency == currency &&
        other.recipient == recipient &&
        other.memo == memo &&
        other.ttlSeconds == ttlSeconds &&
        other.createdAt == createdAt &&
        other.bankCode == bankCode &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      amount,
      currency,
      recipient,
      memo,
      ttlSeconds,
      createdAt,
      bankCode,
      phoneNumber,
    );
  }
}

/// 付款類型枚舉
enum PaymentType {
  /// 台灣QR共通標準
  twqr,

  /// 銀行Deep Link
  bankDeepLink,

  /// 門號轉帳
  phoneTransfer,
}

/// 智慧清償連結結果
class SmartPaymentLink {
  final String url;
  final String deepLinkUrl;
  final String shortUrl;
  final PaymentType type;
  final String? bankName;
  final String? phoneNumber;
  final String? copyText;
  final DateTime createdAt;
  final int ttlSeconds;

  const SmartPaymentLink({
    required this.url,
    required this.deepLinkUrl,
    required this.shortUrl,
    required this.type,
    this.bankName,
    this.phoneNumber,
    this.copyText,
    required this.createdAt,
    required this.ttlSeconds,
  });

  /// 檢查連結是否已過期
  bool get isExpired {
    final expiryTime = createdAt.add(Duration(seconds: ttlSeconds));
    return DateTime.now().isAfter(expiryTime);
  }

  /// 剩餘有效時間（秒）
  int get remainingSeconds {
    if (isExpired) return 0;
    final expiryTime = createdAt.add(Duration(seconds: ttlSeconds));
    return expiryTime.difference(DateTime.now()).inSeconds;
  }

  /// 轉為 JSON
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'deepLinkUrl': deepLinkUrl,
      'shortUrl': shortUrl,
      'type': type.name,
      'bankName': bankName,
      'phoneNumber': phoneNumber,
      'copyText': copyText,
      'createdAt': createdAt.toIso8601String(),
      'ttlSeconds': ttlSeconds,
    };
  }

  /// 從 JSON 創建
  factory SmartPaymentLink.fromJson(Map<String, dynamic> json) {
    return SmartPaymentLink(
      url: json['url'] as String,
      deepLinkUrl: json['deepLinkUrl'] as String,
      shortUrl: json['shortUrl'] as String,
      type: PaymentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentType.twqr,
      ),
      bankName: json['bankName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      copyText: json['copyText'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      ttlSeconds: json['ttlSeconds'] as int,
    );
  }

  @override
  String toString() {
    return 'SmartPaymentLink(type: $type, shortUrl: $shortUrl, bankName: $bankName)';
  }
}

/// 付款方式檢測結果
class PaymentMethod {
  final PaymentType type;
  final String name;
  final String scheme;
  final bool isAvailable;
  final String? reason;
  final String? icon;
  final String? bankCode;

  const PaymentMethod({
    required this.type,
    required this.name,
    required this.scheme,
    required this.isAvailable,
    this.reason,
    this.icon,
    this.bankCode,
  });

  @override
  String toString() {
    return 'PaymentMethod(name: $name, isAvailable: $isAvailable, reason: $reason)';
  }
}

/// 台灣銀行信息
class TaiwanBank {
  final String code;
  final String name;
  final String scheme;
  final String icon;
  final bool isSupported;

  const TaiwanBank({
    required this.code,
    required this.name,
    required this.scheme,
    required this.icon,
    required this.isSupported,
  });

  @override
  String toString() {
    return 'TaiwanBank(code: $code, name: $name, isSupported: $isSupported)';
  }
}
