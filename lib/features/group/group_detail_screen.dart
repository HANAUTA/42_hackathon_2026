// グループ詳細画面。グループ内の投稿を時間帯・日付で切り替えて表示する。
// メンバー一覧・招待コード表示・グループ退出も担当。
// ※ STEP1ではプレースホルダー。Lane C（グループ）で本実装する。

import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  // 表示対象のグループID（ルートの /group/:id から受け取る）。
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'グループ詳細画面（id: $groupId）',
      links: const [
        (label: 'ホームへ戻る', path: '/home'),
      ],
    );
  }
}
