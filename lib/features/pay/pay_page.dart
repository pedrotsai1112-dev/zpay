import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/circular_qr_widget.dart';

class PayPage extends StatefulWidget {
  const PayPage({super.key});

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  int amount = 0;

  @override
  Widget build(BuildContext context) {
    final qrData = "${AppConstants.qrProtocol}pay?to=@demo&amount=$amount&ttl=${AppConstants.qrTtlSeconds}&token=demo-token";
    
    return Scaffold(
      appBar: AppBar(title: const Text('轉帳/收款')),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            // 金額輸入
            Row(
              children: [
                const Text('金額', style: TextStyle(fontSize: 16)),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '輸入金額（可空白）',
                      prefixText: '¥ ',
                    ),
                    onChanged: (v) => setState(() => amount = int.tryParse(v) ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),

            // 圓形 QR Code 組件
            CircularQrWidget(
              data: qrData,
              animated: amount > 0, // 有金額時顯示動畫
              description: '@demo 收款 QR（TTL ${AppConstants.qrTtlSeconds ~/ 60} 分鐘）',
            ),

            const Spacer(),
            // 掃碼按鈕（導到掃描頁）
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push(AppRouter.scan),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('掃描付款 / 加好友'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
