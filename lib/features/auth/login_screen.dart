// ログイン画面。メールログイン / Googleログインを行う。
// ※ STEP1ではプレースホルダー。Lane A（認証）で本実装する。

import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'ログイン画面',
      links: [
        (label: 'プロフィール入力へ（初回）', path: '/profile'),
        (label: 'ホーム画面へ', path: '/home'),
      ],
    );
  }
}
