import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/pay/pay_page.dart';
import 'features/pay/scan_page.dart';
import 'features/split/split_page.dart';
import 'features/friends/friends_page.dart';

void main() {
  runApp(const ZPayApp());
}

class ZPayApp extends StatefulWidget {
  const ZPayApp({super.key});
  @override
  State<ZPayApp> createState() => _ZPayAppState();
}

class _ZPayAppState extends State<ZPayApp> {
  int _index = 0;

  final _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (c, s) => const _HomeShell()),
      GoRoute(path: '/scan', builder: (c, s) => const ScanPage()),
      GoRoute(path: '/split', builder: (c, s) => const SplitPage()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ZPay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C4DFF)),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

/// HomeShell 放底部導航三頁：轉帳/分帳/好友
class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _current = 0;
  final _pages = const [PayPage(), SplitPage(), FriendsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_current],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _current,
        onDestinationSelected: (i) => setState(() => _current = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.qr_code_2), label: '轉帳'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: '分帳'),
          NavigationDestination(icon: Icon(Icons.group), label: '好友'),
        ],
      ),
    );
  }
}
