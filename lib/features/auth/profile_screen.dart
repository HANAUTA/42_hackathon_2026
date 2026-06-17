// プロフィール入力画面。初回ログイン時に名前を登録する。
// ※ STEP1ではプレースホルダー。Lane A（認証）で本実装する。

import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'プロフィール入力画面',
      links: [
        (label: '登録してホームへ', path: '/home'),
      ],
    );
  }
}
