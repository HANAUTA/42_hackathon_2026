// 送信画面。撮影動画をプレビューし、送信先グループを選んで投稿する。
// 1時間制限で送信済みのグループはグレーアウトする。
// ※ STEP1ではプレースホルダー。Lane D（投稿）で本実装する。

import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class SendScreen extends StatelessWidget {
  const SendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: '送信画面',
      links: [
        (label: '送信してホームへ', path: '/home'),
      ],
    );
  }
}
