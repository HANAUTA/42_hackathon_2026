// ホーム画面のデータ取得を担当するProvider群。
// 自分のVlog一覧（posts）と参加中グループ一覧（group_members 経由）を Supabase から取得する。

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase_client.dart';
import '../../models/group.dart';
import '../../models/post.dart';

// ログイン中ユーザーのID。未ログイン時は null。
String? get _currentUserId => supabase.auth.currentUser?.id;

// 自分が投稿したVlog一覧を created_at 降順で取得する。
final myPostsProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
  final userId = _currentUserId;
  if (userId == null) return [];

  final rows = await supabase
      .from('posts')
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false);

  return rows.map<Post>((row) => Post.fromJson(row)).toList();
});

// 自分が参加中のグループ一覧を取得する。
// group_members を起点に groups を結合し、参加日時の新しい順で返す。
final myGroupsProvider = FutureProvider.autoDispose<List<Group>>((ref) async {
  final userId = _currentUserId;
  if (userId == null) return [];

  final rows = await supabase
      .from('group_members')
      .select('groups(*)')
      .eq('user_id', userId)
      .order('joined_at', ascending: false);

  return rows
      .map((row) => row['groups'])
      .whereType<Map<String, dynamic>>()
      .map<Group>((group) => Group.fromJson(group))
      .toList();
});
