import '../constants/app_constants.dart';

/// 台灣金融環境專用驗證工具
class TaiwanValidators {
  /// 驗證台灣手機號碼
  /// 格式：09XXXXXXXX (共10碼)
  static bool isValidTaiwanMobile(String mobile) {
    if (mobile.isEmpty) return false;
    final regex = RegExp(AppConstants.taiwanMobilePattern);
    return regex.hasMatch(mobile);
  }

  /// 驗證台灣市話號碼
  /// 格式：0X-XXXXXXXX 或 0XX-XXXXXXX
  static bool isValidTaiwanPhone(String phone) {
    if (phone.isEmpty) return false;
    final regex = RegExp(AppConstants.taiwanPhonePattern);
    return regex.hasMatch(phone);
  }

  /// 驗證台灣身分證字號
  /// 格式：A123456789 (英文字母+數字9碼)
  static bool isValidTaiwanId(String id) {
    if (id.isEmpty || id.length != 10) return false;
    
    final regex = RegExp(AppConstants.taiwanIdPattern);
    if (!regex.hasMatch(id)) return false;

    // 台灣身分證檢查碼驗證
    return _validateTaiwanIdChecksum(id);
  }

  /// 驗證台灣銀行帳號
  /// 一般為10-16碼數字
  static bool isValidBankAccount(String account) {
    if (account.isEmpty) return false;
    final regex = RegExp(AppConstants.bankAccountPattern);
    return regex.hasMatch(account);
  }

  /// 驗證轉帳金額是否在台灣法規範圍內
  static bool isValidTransferAmount(double amount) {
    return amount >= AppConstants.minTransferAmount && 
           amount <= AppConstants.maxTransferAmount;
  }

  /// 檢查每日轉帳限額
  static bool isWithinDailyLimit(double amount, double todayTotal) {
    return (todayTotal + amount) <= AppConstants.dailyTransferLimit;
  }

  /// 驗證新台幣金額格式
  /// 最多到小數點第2位
  static bool isValidTwdAmount(String amountStr) {
    if (amountStr.isEmpty) return false;
    
    final amount = double.tryParse(amountStr);
    if (amount == null) return false;
    
    // 檢查小數位數不超過2位
    final decimalParts = amountStr.split('.');
    if (decimalParts.length > 2) return false;
    if (decimalParts.length == 2 && decimalParts[1].length > 2) return false;
    
    return amount > 0;
  }

  /// 驗證銀行代碼
  static bool isValidBankCode(String bankCode) {
    return AppConstants.taiwanBankCodes.containsKey(bankCode);
  }

  /// 取得銀行名稱
  static String? getBankName(String bankCode) {
    return AppConstants.taiwanBankCodes[bankCode];
  }

  /// 格式化台灣手機號碼顯示
  /// 09XXXXXXXX -> 09XX-XXX-XXX
  static String formatTaiwanMobile(String mobile) {
    if (!isValidTaiwanMobile(mobile)) return mobile;
    
    return '${mobile.substring(0, 4)}-${mobile.substring(4, 7)}-${mobile.substring(7)}';
  }

  /// 格式化新台幣金額顯示
  /// 1234.5 -> NT$ 1,234.50
  static String formatTwdAmount(double amount) {
    return '${AppConstants.currencySymbol} ${_addCommas(amount.toStringAsFixed(2))}';
  }

  /// 格式化銀行帳號顯示 (部分隱藏)
  /// 1234567890123456 -> 1234-****-****-3456
  static String formatBankAccount(String account, {bool hideMiddle = true}) {
    if (!isValidBankAccount(account)) return account;
    
    if (!hideMiddle || account.length < 8) {
      // 不隱藏或長度不足，按4位分組
      return account.replaceAllMapped(
        RegExp(r'(\d{4})(?=\d)'),
        (match) => '${match.group(1)}-',
      );
    }
    
    // 隱藏中間部分
    final start = account.substring(0, 4);
    final end = account.substring(account.length - 4);
    final middleStars = '*' * (account.length - 8);
    
    return '$start-$middleStars-$end';
  }

  /// 身分證字號檢查碼驗證
  static bool _validateTaiwanIdChecksum(String id) {
    // 台灣身分證字母對應數字表
    const letterValues = {
      'A': 10, 'B': 11, 'C': 12, 'D': 13, 'E': 14, 'F': 15, 'G': 16,
      'H': 17, 'I': 34, 'J': 18, 'K': 19, 'L': 20, 'M': 21, 'N': 22,
      'O': 35, 'P': 23, 'Q': 24, 'R': 25, 'S': 26, 'T': 27, 'U': 28,
      'V': 29, 'W': 32, 'X': 30, 'Y': 31, 'Z': 33
    };

    final firstLetter = id[0];
    final letterValue = letterValues[firstLetter];
    if (letterValue == null) return false;

    // 計算檢查碼
    int sum = (letterValue ~/ 10) + (letterValue % 10) * 9;
    
    for (int i = 1; i < 9; i++) {
      sum += int.parse(id[i]) * (9 - i);
    }
    
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(id[9]);
  }

  /// 為數字添加千分位逗號
  static String _addCommas(String numberStr) {
    final parts = numberStr.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
    
    final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    final formattedInteger = integerPart.replaceAllMapped(
      regex,
      (match) => '${match.group(1)},',
    );
    
    return formattedInteger + decimalPart;
  }
}

/// 台灣金融錯誤訊息
class TaiwanFinanceMessages {
  static const String invalidMobile = '請輸入正確的台灣手機號碼格式 (09XXXXXXXX)';
  static const String invalidPhone = '請輸入正確的台灣市話號碼格式';
  static const String invalidId = '請輸入正確的台灣身分證字號';
  static const String invalidBankAccount = '請輸入正確的銀行帳號 (10-16碼數字)';
  static const String invalidBankCode = '請選擇正確的銀行代碼';
  static const String amountTooSmall = '轉帳金額不得小於 NT\$ 1';
  static const String amountTooLarge = '單筆轉帳金額不得超過 NT\$ 50,000';
  static const String dailyLimitExceeded = '已達每日轉帳限額 NT\$ 200,000';
  static const String invalidAmountFormat = '請輸入正確的金額格式';
  
  /// 根據錯誤類型取得對應訊息
  static String getValidationMessage(TaiwanValidationError error) {
    switch (error) {
      case TaiwanValidationError.invalidMobile:
        return invalidMobile;
      case TaiwanValidationError.invalidPhone:
        return invalidPhone;
      case TaiwanValidationError.invalidId:
        return invalidId;
      case TaiwanValidationError.invalidBankAccount:
        return invalidBankAccount;
      case TaiwanValidationError.invalidBankCode:
        return invalidBankCode;
      case TaiwanValidationError.amountTooSmall:
        return amountTooSmall;
      case TaiwanValidationError.amountTooLarge:
        return amountTooLarge;
      case TaiwanValidationError.dailyLimitExceeded:
        return dailyLimitExceeded;
      case TaiwanValidationError.invalidAmountFormat:
        return invalidAmountFormat;
    }
  }
}

/// 台灣金融驗證錯誤類型
enum TaiwanValidationError {
  invalidMobile,
  invalidPhone,
  invalidId,
  invalidBankAccount,
  invalidBankCode,
  amountTooSmall,
  amountTooLarge,
  dailyLimitExceeded,
  invalidAmountFormat,
}
