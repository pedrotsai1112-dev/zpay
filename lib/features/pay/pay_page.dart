import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PayPage extends StatefulWidget {
  const PayPage({super.key});

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  int amount = 0;

  @override
  Widget build(BuildContext context) {
    final qrData = "zpay://pay?to=@demo&amount=$amount&ttl=300&token=demo-token";
    return Scaffold(
      appBar: AppBar(title: const Text('轉帳/收款')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 金額輸入
            Row(
              children: [
                const Text('金額', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '輸入金額（可空白）',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => amount = int.tryParse(v) ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 圓形 QR 外觀包裝（內部仍為方形 QR）
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 動態外環（此版先靜態）
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(colors: [
                        Color(0xFF7C4DFF),
                        Color(0xFF03A9F4),
                        Color(0xFF00E5FF),
                        Color(0xFF7C4DFF),
                      ]),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 12, spreadRadius: 1),
                      ],
                    ),
                  ),
                  // 白色圓形底，留出方形QR的安靜區
                  Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  // 方形 QR（標準，確保可掃）
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                    gapless: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('@demo 收款 QR（TTL 5 分鐘）', style: Theme.of(context).textTheme.bodySmall),

            const Spacer(),
            // 掃碼按鈕（導到掃描頁）
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/scan'),
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
