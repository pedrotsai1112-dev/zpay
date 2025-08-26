# 💰 ZPay - 智能分帳支付 App

> 一個基於 Flutter 的現代化金融支付應用，專注於轉帳、分帳和好友管理功能。

## 🚀 專案概述

ZPay 是一個創新的支付應用，結合了傳統轉帳功能與智能分帳特性，為用戶提供便捷的金融服務體驗。

### 核心功能
- 🔄 **轉帳/收款**: 美觀的圓形 QR Code 設計
- 📊 **智能分帳**: AI 自然語言處理分帳需求
- 👥 **好友管理**: 簡化的社交網絡功能
- 📱 **跨平台**: iOS 和 Android 原生體驗

## 📋 開發進度

### ✅ 已完成（超前進度）
- [x] 環境建置完成（Week 1）
  - Homebrew / Flutter / Android Studio / Xcode / CocoaPods
  - iOS 模擬器可成功跑起 App
- [x] 專案骨架（Week 1~2 預定）
  - Flutter 專案、GitHub 版控
  - 三大核心頁面雛形：轉帳（含圓形QR UI） / 分帳 / 好友
  - 路由與底部導覽

### 🚧 進行中
- [ ] UI/UX 設計系統完善
- [ ] 狀態管理架構建立
- [ ] AI 分帳邏輯實現

### 📅 計劃中
- [ ] 用戶認證系統
- [ ] 後端 API 整合
- [ ] 支付網關接入
- [ ] 測試與優化

## 🛠 技術架構

### 核心技術棧
- **Frontend**: Flutter 3.9+ (Dart)
- **狀態管理**: flutter_riverpod 2.6.1
- **路由**: go_router 16.2.0
- **QR Code**: qr_flutter 4.1.0 + mobile_scanner 7.0.1
- **版本控制**: Git + GitHub

### 專案結構
```
lib/
├── features/           # 功能模組
│   ├── pay/           # 轉帳功能
│   │   ├── pay_page.dart       # 轉帳主頁
│   │   └── scan_page.dart      # QR 掃描頁
│   ├── split/         # 分帳功能
│   │   └── split_page.dart     # 分帳主頁
│   └── friends/       # 好友管理
│       └── friends_page.dart   # 好友列表
├── shared/            # 共享組件（計劃中）
├── core/              # 核心配置（計劃中）
└── main.dart          # 應用入口
```

## 🎨 設計特色

### UI/UX 亮點
- **圓形 QR Code**: 創新的漸層圓環包裹設計，兼顧美觀與實用
- **Material 3**: 現代化的設計語言，一致的視覺體驗
- **智能分帳**: 自然語言輸入，AI 智能解析分帳需求
- **流暢導航**: 直觀的底部導航，快速切換功能

### 色彩系統
- **主色**: Purple (#7C4DFF) - 科技感與信任感
- **輔助色**: Blue (#03A9F4, #00E5FF) - 活力與現代感
- **漸層設計**: 動態感的視覺呈現

## 🚀 快速開始

### 環境要求
- Flutter SDK 3.9.0+
- Dart SDK 3.0.0+
- iOS 11.0+ / Android API 21+
- Xcode 14+ (iOS 開發)
- Android Studio (Android 開發)

### 安裝步驟
```bash
# 克隆專案
git clone https://github.com/pedrotsai1112-dev/zpay.git
cd zpay/zpay_app

# 安裝依賴
flutter pub get

# iOS 設置（如需）
cd ios && pod install && cd ..

# 運行應用
flutter run
```

### 開發命令
```bash
# 代碼檢查
flutter analyze

# 測試運行
flutter test

# 構建生產版本
flutter build apk --release    # Android
flutter build ios --release    # iOS
```

## 📱 功能預覽

### 轉帳頁面
- 金額輸入框
- 動態圓形 QR Code 生成
- 掃描付款按鈕
- TTL 時間顯示

### 分帳頁面
- 自然語言輸入框
- AI 分帳按鈕（Day 2 整合）
- 分帳結果預覽

### 好友頁面
- 好友列表展示
- 快速分帳/轉帳按鈕
- 新增好友功能

## 🔧 開發工具配置

### VS Code / Cursor 插件推薦
- Flutter
- Dart
- Flutter Riverpod Snippets
- Flutter Widget Snippets
- GitLens

### 代碼格式化
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_print: true
```

## 🤝 貢獻指南

### 代碼風格
- 遵循 Dart 官方風格指南
- 使用 `flutter format` 格式化代碼
- Commit 信息使用中文描述

### 分支策略
- `main`: 主分支，穩定版本
- `develop`: 開發分支
- `feature/*`: 功能分支
- `fix/*`: 修復分支

## 📄 許可證

MIT License - 詳見 [LICENSE](LICENSE) 文件

## 📞 聯絡方式

- **開發者**: Peter Tsai
- **GitHub**: [@pedrotsai1112-dev](https://github.com/pedrotsai1112-dev)
- **專案**: [ZPay Repository](https://github.com/pedrotsai1112-dev/zpay)

---

**ZPay** - 讓分帳變得簡單，讓支付變得美好 💫