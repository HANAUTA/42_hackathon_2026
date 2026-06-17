// スプラッシュ画面。起動時にログイン状態を確認し、ログイン画面 or ホームへ分岐する。
// ※ STEP1ではプレースホルダー。Lane A（認証）で本実装する。

import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'スプラッシュ画面',
      links: [
        (label: 'ログイン画面へ', path: '/login'),
        (label: 'ホーム画面へ（仮）', path: '/home'),
      ],
    );
  }
}
