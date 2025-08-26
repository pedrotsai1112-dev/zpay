import '../models/qr_data.dart';
import '../models/result.dart';

/// QR Code 解析和生成服務
class QrParsingService {
  /// ZPay 協議前綴
  static const String _zpayProtocol = 'zpay://';

  /// 解析 QR Code 字符串
  Result<QrData> parseQrCode(String qrString) {
    if (qrString.isEmpty) {
      return Result.failure('QR Code 內容不能為空');
    }

    try {
      // 檢查是否為 ZPay 協議
      if (qrString.startsWith(_zpayProtocol)) {
        return _parseZPayProtocol(qrString);
      }

      // 檢查是否為網址
      if (_isUrl(qrString)) {
        return Result.success(QrData.url(qrString));
      }

      // 默認為純文字
      return Result.success(QrData.text(qrString));
    } catch (e) {
      return Result.failure('解析 QR Code 時發生錯誤: ${e.toString()}');
    }
  }

  /// 生成 QR Code 字符串
  String generateQrString(QrData qrData) {
    switch (qrData.type) {
      case QrCodeType.payment:
        return _generatePaymentQr(qrData);
      case QrCodeType.addFriend:
        return _generateFriendQr(qrData);
      case QrCodeType.splitInvite:
        return _generateSplitQr(qrData);
      case QrCodeType.url:
        return qrData.url!;
      case QrCodeType.text:
        return qrData.text!;
    }
  }

  /// 解析 ZPay 協議
  Result<QrData> _parseZPayProtocol(String qrString) {
    try {
      final uri = Uri.parse(qrString);
      
      switch (uri.host) {
        case 'pay':
          return _parsePaymentQr(uri);
        case 'friend':
          return _parseFriendQr(uri);
        case 'split':
          return _parseSplitQr(uri);
        default:
          return Result.failure('不支援的 ZPay 協議: ${uri.host}');
      }
    } catch (e) {
      return Result.failure('ZPay 協議格式錯誤: ${e.toString()}');
    }
  }

  /// 解析支付 QR Code
  Result<QrData> _parsePaymentQr(Uri uri) {
    final params = uri.queryParameters;
    
    final recipient = params['to'];
    if (recipient == null || recipient.isEmpty) {
      return Result.failure('支付 QR Code 缺少收款人信息');
    }

    final amountStr = params['amount'];
    double? amount;
    if (amountStr != null && amountStr.isNotEmpty) {
      amount = double.tryParse(amountStr);
      if (amount == null) {
        return Result.failure('支付金額格式錯誤');
      }
    }

    final ttlStr = params['ttl'];
    int? ttl;
    if (ttlStr != null && ttlStr.isNotEmpty) {
      ttl = int.tryParse(ttlStr);
      if (ttl == null) {
        return Result.failure('TTL 格式錯誤');
      }
    }

    final token = params['token'];
    final memo = params['memo'];

    try {
      final qrData = QrData.payment(
        recipient: recipient,
        amount: amount,
        ttl: ttl,
        token: token,
        memo: memo,
      );
      return Result.success(qrData);
    } catch (e) {
      return Result.failure('創建支付 QR 數據失敗: ${e.toString()}');
    }
  }

  /// 解析加好友 QR Code
  Result<QrData> _parseFriendQr(Uri uri) {
    final params = uri.queryParameters;
    
    final user = params['user'];
    if (user == null || user.isEmpty) {
      return Result.failure('加好友 QR Code 缺少用戶信息');
    }

    final nickname = params['nickname'];
    final avatarUrl = params['avatar'];

    try {
      final qrData = QrData.addFriend(
        user: user,
        nickname: nickname,
        avatarUrl: avatarUrl,
      );
      return Result.success(qrData);
    } catch (e) {
      return Result.failure('創建加好友 QR 數據失敗: ${e.toString()}');
    }
  }

  /// 解析分帳邀請 QR Code
  Result<QrData> _parseSplitQr(Uri uri) {
    final params = uri.queryParameters;
    
    final splitId = params['id'];
    if (splitId == null || splitId.isEmpty) {
      return Result.failure('分帳邀請 QR Code 缺少 ID');
    }

    final title = params['title'];
    if (title == null || title.isEmpty) {
      return Result.failure('分帳邀請 QR Code 缺少標題');
    }

    final amountStr = params['amount'];
    if (amountStr == null || amountStr.isEmpty) {
      return Result.failure('分帳邀請 QR Code 缺少金額');
    }

    final amount = double.tryParse(amountStr);
    if (amount == null) {
      return Result.failure('分帳金額格式錯誤');
    }

    final participantsStr = params['participants'];
    if (participantsStr == null || participantsStr.isEmpty) {
      return Result.failure('分帳邀請 QR Code 缺少參與人數');
    }

    final participantCount = int.tryParse(participantsStr);
    if (participantCount == null) {
      return Result.failure('參與人數格式錯誤');
    }

    final creator = params['creator'];
    if (creator == null || creator.isEmpty) {
      return Result.failure('分帳邀請 QR Code 缺少創建者');
    }

    try {
      final qrData = QrData.splitInvite(
        splitId: splitId,
        title: title,
        amount: amount,
        participantCount: participantCount,
        creator: creator,
      );
      return Result.success(qrData);
    } catch (e) {
      return Result.failure('創建分帳邀請 QR 數據失敗: ${e.toString()}');
    }
  }

  /// 生成支付 QR Code
  String _generatePaymentQr(QrData qrData) {
    final params = <String, String>{
      'to': qrData.recipient!,
    };

    if (qrData.amount != null) {
      params['amount'] = qrData.amount.toString();
    }

    if (qrData.ttl != null) {
      params['ttl'] = qrData.ttl.toString();
    }

    if (qrData.token != null && qrData.token!.isNotEmpty) {
      params['token'] = qrData.token!;
    }

    if (qrData.memo != null && qrData.memo!.isNotEmpty) {
      params['memo'] = qrData.memo!;
    }

    final uri = Uri(
      scheme: 'zpay',
      host: 'pay',
      queryParameters: params,
    );

    return uri.toString();
  }

  /// 生成加好友 QR Code
  String _generateFriendQr(QrData qrData) {
    final params = <String, String>{
      'user': qrData.recipient!,
    };

    if (qrData.nickname != null && qrData.nickname!.isNotEmpty) {
      params['nickname'] = qrData.nickname!;
    }

    if (qrData.avatarUrl != null && qrData.avatarUrl!.isNotEmpty) {
      params['avatar'] = qrData.avatarUrl!;
    }

    final uri = Uri(
      scheme: 'zpay',
      host: 'friend',
      queryParameters: params,
    );

    return uri.toString();
  }

  /// 生成分帳邀請 QR Code
  String _generateSplitQr(QrData qrData) {
    final params = <String, String>{
      'id': qrData.splitId!,
      'title': qrData.title!,
      'amount': qrData.amount.toString(),
      'participants': qrData.participantCount.toString(),
      'creator': qrData.creator!,
    };

    final uri = Uri(
      scheme: 'zpay',
      host: 'split',
      queryParameters: params,
    );

    return uri.toString();
  }

  /// 檢查字符串是否為網址
  bool _isUrl(String text) {
    try {
      final uri = Uri.parse(text);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
