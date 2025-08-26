/// ZPay 應用常量定義 - 台灣金融環境
class AppConstants {
  // 應用信息
  static const String appName = 'ZPay';
  static const String appVersion = '1.0.0';
  static const String appDescription = '台灣智能分帳支付 App';
  
  // 台灣在地化設定
  static const String countryCode = 'TW';
  static const String currencyCode = 'TWD';
  static const String currencySymbol = 'NT\$';
  static const String timeZone = 'Asia/Taipei';
  static const String localeCode = 'zh_TW';

  // QR Code 相關
  static const String qrProtocol = 'zpay://';
  static const int qrTtlSeconds = 300; // 5 分鐘
  static const double qrSize = 180.0;
  static const double qrContainerSize = 260.0;
  static const double qrCircleSize = 240.0;
  static const double qrBackgroundSize = 220.0;

  // 台灣金融 API 相關
  static const String apiBaseUrl = 'https://api.zpay.tw'; // 台灣網域
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // 台灣開放銀行 API 設定
  static const String openBankingBaseUrl = 'https://openapi.fisc.com.tw'; // 財金公司
  static const String oauth2AuthorizeUrl = '/oauth2/authorize';
  static const String oauth2TokenUrl = '/oauth2/token';
  
  // 台灣銀行代碼 (前10大銀行)
  static const Map<String, String> taiwanBankCodes = {
    '004': '台灣銀行',
    '005': '土地銀行', 
    '006': '合作金庫',
    '007': '第一銀行',
    '008': '華南銀行',
    '009': '彰化銀行',
    '011': '上海商銀',
    '012': '台北富邦',
    '013': '國泰世華',
    '017': '兆豐銀行',
  };

  // 台灣用戶相關限制
  static const int maxFriendsCount = 500;
  static const int maxSplitParticipants = 20;
  static const double minTransferAmount = 1.0; // 最小轉帳 NT$1
  static const double maxTransferAmount = 50000.0; // 單筆最高 NT$50,000
  static const double dailyTransferLimit = 200000.0; // 每日限額 NT$200,000
  
  // 台灣手機號碼格式
  static const String taiwanMobilePattern = r'^09\d{8}$'; // 09XXXXXXXX
  static const String taiwanPhonePattern = r'^0\d{1,2}-?\d{6,8}$'; // 市話格式
  
  // 台灣身分證格式
  static const String taiwanIdPattern = r'^[A-Z][12]\d{8}$';
  
  // 台灣銀行帳號格式 (各銀行略有不同，這是通用格式)
  static const String bankAccountPattern = r'^\d{10,16}$';

  // UI 相關
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
  static const int maxUsernameLength = 20;
  static const int maxDescriptionLength = 100;

  // 分帳相關
  static const List<String> splitKeywords = [
    '我幫', '我付', '我出', '代付', '先付',
    '平分', '均分', 'AA', 'aa',
    '人', '個人', '大家', '朋友',
  ];

  // 錯誤信息
  static const String errorNetworkTitle = '網絡連接異常';
  static const String errorNetworkMessage = '請檢查網絡連接後重試';
  static const String errorServerTitle = '服務器異常';
  static const String errorServerMessage = '服務暫時不可用，請稍後重試';
  static const String errorUnknownTitle = '未知錯誤';
  static const String errorUnknownMessage = '發生了未知錯誤，請重試';

  // 成功信息
  static const String successTransferTitle = '轉帳成功';
  static const String successSplitTitle = '分帳創建成功';
  static const String successFriendAddedTitle = '好友添加成功';

  // 本地存儲 Key
  static const String keyUserProfile = 'user_profile';
  static const String keyFriendsList = 'friends_list';
  static const String keyTransferHistory = 'transfer_history';
  static const String keySplitHistory = 'split_history';
  static const String keyAppSettings = 'app_settings';
  static const String keyFirstLaunch = 'first_launch';
}
