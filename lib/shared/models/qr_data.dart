/// QR Code 類型枚舉
enum QrCodeType {
  /// 支付 QR Code
  payment,
  
  /// 加好友 QR Code
  addFriend,
  
  /// 分帳邀請 QR Code
  splitInvite,
  
  /// 一般網址
  url,
  
  /// 純文字
  text,
}

/// QR Code 數據模型
class QrData {
  /// QR Code 類型
  final QrCodeType type;
  
  /// 創建時間
  final DateTime createdAt;
  
  // 支付相關
  final String? recipient;
  final double? amount;
  final int? ttl; // Time to live in seconds
  final String? token;
  final String? memo;
  
  // 好友相關
  final String? nickname;
  final String? avatarUrl;
  
  // 分帳相關
  final String? splitId;
  final String? title;
  final int? participantCount;
  final String? creator;
  
  // 通用
  final String? url;
  final String? text;

  QrData._({
    required this.type,
    required this.createdAt,
    this.recipient,
    this.amount,
    this.ttl,
    this.token,
    this.memo,
    this.nickname,
    this.avatarUrl,
    this.splitId,
    this.title,
    this.participantCount,
    this.creator,
    this.url,
    this.text,
  });

  /// 創建支付 QR Code 數據
  factory QrData.payment({
    required String recipient,
    double? amount,
    int? ttl,
    String? token,
    String? memo,
    DateTime? createdAt,
  }) {
    if (recipient.isEmpty) {
      throw ArgumentError('收款人不能為空');
    }
    if (amount != null && amount <= 0) {
      throw ArgumentError('支付金額必須大於零');
    }
    if (ttl != null && ttl <= 0) {
      throw ArgumentError('TTL 必須大於零');
    }

    return QrData._(
      type: QrCodeType.payment,
      createdAt: createdAt ?? DateTime.now(),
      recipient: recipient,
      amount: amount,
      ttl: ttl,
      token: token,
      memo: memo,
    );
  }

  /// 創建加好友 QR Code 數據
  factory QrData.addFriend({
    required String user,
    String? nickname,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    if (user.isEmpty) {
      throw ArgumentError('用戶名不能為空');
    }

    return QrData._(
      type: QrCodeType.addFriend,
      createdAt: createdAt ?? DateTime.now(),
      recipient: user,
      nickname: nickname,
      avatarUrl: avatarUrl,
    );
  }

  /// 創建分帳邀請 QR Code 數據
  factory QrData.splitInvite({
    required String splitId,
    required String title,
    required double amount,
    required int participantCount,
    required String creator,
    DateTime? createdAt,
  }) {
    if (splitId.isEmpty) {
      throw ArgumentError('分帳 ID 不能為空');
    }
    if (title.isEmpty) {
      throw ArgumentError('分帳標題不能為空');
    }
    if (amount <= 0) {
      throw ArgumentError('分帳金額必須大於零');
    }
    if (participantCount <= 1) {
      throw ArgumentError('參與人數必須大於 1');
    }
    if (creator.isEmpty) {
      throw ArgumentError('創建者不能為空');
    }

    return QrData._(
      type: QrCodeType.splitInvite,
      createdAt: createdAt ?? DateTime.now(),
      splitId: splitId,
      title: title,
      amount: amount,
      participantCount: participantCount,
      creator: creator,
    );
  }

  /// 創建網址 QR Code 數據
  factory QrData.url(String url, {DateTime? createdAt}) {
    if (url.isEmpty) {
      throw ArgumentError('網址不能為空');
    }

    return QrData._(
      type: QrCodeType.url,
      createdAt: createdAt ?? DateTime.now(),
      url: url,
    );
  }

  /// 創建文字 QR Code 數據
  factory QrData.text(String text, {DateTime? createdAt}) {
    if (text.isEmpty) {
      throw ArgumentError('文字不能為空');
    }

    return QrData._(
      type: QrCodeType.text,
      createdAt: createdAt ?? DateTime.now(),
      text: text,
    );
  }

  /// 檢查 QR Code 是否已過期
  bool get isExpired {
    if (ttl == null || ttl! <= 0) return false;
    final expiryTime = createdAt.add(Duration(seconds: ttl!));
    return DateTime.now().isAfter(expiryTime);
  }

  /// 獲取剩餘有效時間（秒）
  int? get remainingTtl {
    if (ttl == null || ttl! <= 0) return null;
    final expiryTime = createdAt.add(Duration(seconds: ttl!));
    final remaining = expiryTime.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  @override
  String toString() {
    switch (type) {
      case QrCodeType.payment:
        return 'QrData.payment(recipient: $recipient, amount: $amount, ttl: $ttl)';
      case QrCodeType.addFriend:
        return 'QrData.addFriend(user: $recipient, nickname: $nickname)';
      case QrCodeType.splitInvite:
        return 'QrData.splitInvite(id: $splitId, title: $title, amount: $amount)';
      case QrCodeType.url:
        return 'QrData.url($url)';
      case QrCodeType.text:
        return 'QrData.text($text)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QrData) return false;
    
    return type == other.type &&
           recipient == other.recipient &&
           amount == other.amount &&
           ttl == other.ttl &&
           token == other.token &&
           memo == other.memo &&
           nickname == other.nickname &&
           avatarUrl == other.avatarUrl &&
           splitId == other.splitId &&
           title == other.title &&
           participantCount == other.participantCount &&
           creator == other.creator &&
           url == other.url &&
           text == other.text;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      type,
      recipient,
      amount,
      ttl,
      token,
      memo,
      nickname,
      avatarUrl,
      splitId,
      title,
      participantCount,
      creator,
      url,
      text,
    ]);
  }
}
