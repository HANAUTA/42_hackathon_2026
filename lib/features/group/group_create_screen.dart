// グループ作成画面。グループ名を入力し、招待コードを自動生成して作成・自動参加する。
// ※ STEP1ではプレースホルダー。Lane C（グループ）で本実装する。

import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class GroupCreateScreen extends StatelessWidget {
  const GroupCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'グループ作成画面',
      links: [
        (label: '作成してホームへ', path: '/home'),
      ],
    );
  }
}
