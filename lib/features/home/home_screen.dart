// ホーム画面。自分のVlog一覧と参加中グループ一覧を表示する。
// ※ STEP1ではプレースホルダー。Lane B（ホーム）で本実装する。

import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'ホーム画面',
      links: [
        (label: 'ログ作成（撮影）', path: '/camera'),
        (label: 'グループ作成', path: '/group/create'),
        (label: 'グループ参加', path: '/group/join'),
        (label: 'グループ詳細（仮ID）', path: '/group/sample-id'),
      ],
    );
  }
}
