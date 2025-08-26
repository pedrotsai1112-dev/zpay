import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../shared/services/qr_parsing_service.dart';
import '../../shared/models/qr_data.dart';
import '../../core/theme/app_theme.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final QrParsingService _qrParsingService = QrParsingService();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('掃描 QR'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // 掃描器
          MobileScanner(
            onDetect: _isProcessing ? null : _handleQrDetected,
          ),
          
          // 掃描框和指引
          _buildScanOverlay(),
          
          // 底部指引文字
          _buildBottomGuide(),
        ],
      ),
    );
  }

  /// 建立掃描覆蓋層
  Widget _buildScanOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.primaryPurple,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: Stack(
          children: [
            // 四個角的裝飾
            _buildCornerDecoration(Alignment.topLeft),
            _buildCornerDecoration(Alignment.topRight),
            _buildCornerDecoration(Alignment.bottomLeft),
            _buildCornerDecoration(Alignment.bottomRight),
          ],
        ),
      ),
    );
  }

  /// 建立角落裝飾
  Widget _buildCornerDecoration(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryPurple, width: 3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// 建立底部指引
  Widget _buildBottomGuide() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: const Column(
              children: [
                Text(
                  '將 QR Code 對準掃描框',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.spacingS),
                Text(
                  '支援 ZPay 轉帳、加好友、分帳邀請',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (_isProcessing) ...[
            const SizedBox(height: AppTheme.spacingM),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
            ),
            const SizedBox(height: AppTheme.spacingS),
            const Text(
              '處理中...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  /// 處理 QR Code 掃描結果
  void _handleQrDetected(BarcodeCapture capture) {
    if (_isProcessing) return;
    
    final codes = capture.barcodes;
    if (codes.isEmpty) return;
    
    final rawValue = codes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    // 解析 QR Code
    final result = _qrParsingService.parseQrCode(rawValue);
    
    if (result.isSuccess && result.data != null) {
      _handleSuccessfulScan(result.data!);
    } else {
      _handleScanError(result.error ?? '無法識別的 QR Code');
    }
  }

  /// 處理成功掃描
  void _handleSuccessfulScan(QrData qrData) {
    switch (qrData.type) {
      case QrCodeType.payment:
        _showPaymentDialog(qrData);
        break;
      case QrCodeType.addFriend:
        _showAddFriendDialog(qrData);
        break;
      case QrCodeType.splitInvite:
        _showSplitInviteDialog(qrData);
        break;
      case QrCodeType.url:
        _showUrlDialog(qrData);
        break;
      case QrCodeType.text:
        _showTextDialog(qrData);
        break;
    }
  }

  /// 處理掃描錯誤
  void _handleScanError(String error) {
    setState(() {
      _isProcessing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('掃描錯誤: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// 顯示支付確認對話框
  void _showPaymentDialog(QrData qrData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認轉帳'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('收款人: ${qrData.recipient}'),
            if (qrData.amount != null) Text('金額: ¥${qrData.amount}'),
            if (qrData.memo != null) Text('備註: ${qrData.memo}'),
            if (qrData.isExpired) 
              const Text(
                '⚠️ 此 QR Code 已過期',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _cancelAndResume,
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: qrData.isExpired ? null : () => _confirmPayment(qrData),
            child: const Text('確認轉帳'),
          ),
        ],
      ),
    );
  }

  /// 顯示加好友對話框
  void _showAddFriendDialog(QrData qrData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加好友'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('用戶名: ${qrData.recipient}'),
            if (qrData.nickname != null) Text('暱稱: ${qrData.nickname}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _cancelAndResume,
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => _confirmAddFriend(qrData),
            child: const Text('添加好友'),
          ),
        ],
      ),
    );
  }

  /// 顯示分帳邀請對話框
  void _showSplitInviteDialog(QrData qrData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('分帳邀請'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('標題: ${qrData.title}'),
            Text('總金額: ¥${qrData.amount}'),
            Text('參與人數: ${qrData.participantCount}'),
            Text('發起人: ${qrData.creator}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _cancelAndResume,
            child: const Text('拒絕'),
          ),
          FilledButton(
            onPressed: () => _confirmJoinSplit(qrData),
            child: const Text('參與分帳'),
          ),
        ],
      ),
    );
  }

  /// 顯示網址對話框
  void _showUrlDialog(QrData qrData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('網址 QR Code'),
        content: Text('網址: ${qrData.url}'),
        actions: [
          TextButton(
            onPressed: _cancelAndResume,
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => _openUrl(qrData.url!),
            child: const Text('打開網址'),
          ),
        ],
      ),
    );
  }

  /// 顯示文字對話框
  void _showTextDialog(QrData qrData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('文字 QR Code'),
        content: Text(qrData.text!),
        actions: [
          TextButton(
            onPressed: _cancelAndResume,
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  /// 取消並恢復掃描
  void _cancelAndResume() {
    Navigator.of(context).pop();
    setState(() {
      _isProcessing = false;
    });
  }

  /// 確認轉帳
  void _confirmPayment(QrData qrData) {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    // TODO: 導航到轉帳確認頁面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('轉帳到 ${qrData.recipient}')),
    );
  }

  /// 確認添加好友
  void _confirmAddFriend(QrData qrData) {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    // TODO: 執行添加好友邏輯
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已添加好友 ${qrData.recipient}')),
    );
  }

  /// 確認參與分帳
  void _confirmJoinSplit(QrData qrData) {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    // TODO: 導航到分帳詳情頁面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已參與分帳 ${qrData.title}')),
    );
  }

  /// 打開網址
  void _openUrl(String url) {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    // TODO: 使用 url_launcher 打開網址
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('打開網址: $url')),
    );
  }
}
