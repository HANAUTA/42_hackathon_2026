// アプリ全体の画面遷移（ルーティング）を定義。
// 全ルートをここに集約する。画面内で直接 Navigator.push は使わない。

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/profile_screen.dart';
import '../features/home/home_screen.dart';
import '../features/group/group_create_screen.dart';
import '../features/group/group_join_screen.dart';
import '../features/group/group_detail_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/post/camera_screen.dart';
import '../features/post/send_screen.dart';

// アプリのルーター。起動時はスプラッシュ画面から始まる。
final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/group/create',
      builder: (context, state) => const GroupCreateScreen(),
    ),
    GoRoute(
      path: '/group/join',
      builder: (context, state) => const GroupJoinScreen(),
    ),
    GoRoute(
      path: '/group/:id',
      builder: (context, state) =>
          GroupDetailScreen(groupId: state.pathParameters['id']!),
    ),
    // カメラはボタンが左にあるため、左からスライドして遷移させる。
    GoRoute(
      path: '/camera',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const CameraScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          );
        },
      ),
    ),
    GoRoute(path: '/send', builder: (context, state) => const SendScreen()),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
  ],
);
