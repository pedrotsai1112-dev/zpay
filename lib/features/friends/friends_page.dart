import 'package:flutter/material.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final demoFriends = ['@alice', '@bob', '@charlie', '@diana'];
    return Scaffold(
      appBar: AppBar(title: const Text('好友')),
      body: ListView.separated(
        itemCount: demoFriends.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final tag = demoFriends[i];
          return ListTile(
            leading: CircleAvatar(child: Text(tag.substring(1,2).toUpperCase())),
            title: Text(tag),
            trailing: FilledButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/split'); // 之後可改為「和此人分帳/轉帳」
              },
              child: const Text('成團/分帳'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, // 之後：掃好友圓形QR / 分享邀請連結
        icon: const Icon(Icons.group_add),
        label: const Text('新增好友/群組'),
      ),
    );
  }
}
