/// ZPay 應用常量定義
class AppConstants {
  // 應用信息
  static const String appName = 'ZPay';
  static const String appVersion = '1.0.0';
  static const String appDescription = '智能分帳支付 App';

  // QR Code 相關
  static const String qrProtocol = 'zpay://';
  static const int qrTtlSeconds = 300; // 5 分鐘
  static const double qrSize = 180.0;
  static const double qrContainerSize = 260.0;
  static const double qrCircleSize = 240.0;
  static const double qrBackgroundSize = 220.0;

  // API 相關（未來使用）
  static const String apiBaseUrl = 'https://api.zpay.app';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // 用戶相關
  static const int maxFriendsCount = 500;
  static const int maxSplitParticipants = 20;
  static const double minTransferAmount = 1.0;
  static const double maxTransferAmount = 50000.0;

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
