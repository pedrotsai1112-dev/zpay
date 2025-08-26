import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/pay/pay_page.dart';
import '../../features/pay/scan_page.dart';
import '../../features/split/split_page.dart';
import '../../features/friends/friends_page.dart';

/// 應用路由配置
class AppRouter {
  static const String home = '/';
  static const String scan = '/scan';
  static const String split = '/split';
  static const String friends = '/friends';

  /// GoRouter 配置
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      // 主頁殼層（包含底部導航）
      GoRoute(
        path: home,
        builder: (context, state) => const _HomeShell(),
      ),
      
      // 掃描頁面（全屏）
      GoRoute(
        path: scan,
        builder: (context, state) => const ScanPage(),
      ),
      
      // 分帳頁面（全屏，未來可能需要）
      GoRoute(
        path: split,
        builder: (context, state) => const SplitPage(),
      ),
    ],
  );
}

/// 主頁殼層 - 包含底部導航的三個核心頁面
class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    PayPage(),
    SplitPage(),
    FriendsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.qr_code_2),
            selectedIcon: Icon(Icons.qr_code_2),
            label: '轉帳',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            selectedIcon: Icon(Icons.receipt_long),
            label: '分帳',
          ),
          NavigationDestination(
            icon: Icon(Icons.group),
            selectedIcon: Icon(Icons.group),
            label: '好友',
          ),
        ],
      ),
    );
  }
}
