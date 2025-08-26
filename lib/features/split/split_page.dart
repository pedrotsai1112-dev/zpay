import 'package:flutter/material.dart';

class SplitPage extends StatelessWidget {
  const SplitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('分帳')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: '自然語句輸入（例：我幫4個人付了500）',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: null, // Day 2 會接 AI 分帳
                child: const Text('AI 分帳（Day 2 接）'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
