// グループ参加画面。招待コードを入力してグループに参加する。
// ※ STEP1ではプレースホルダー。Lane C（グループ）で本実装する。

import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class GroupJoinScreen extends StatelessWidget {
  const GroupJoinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'グループ参加画面',
      links: [
        (label: '参加してホームへ', path: '/home'),
      ],
    );
  }
}
