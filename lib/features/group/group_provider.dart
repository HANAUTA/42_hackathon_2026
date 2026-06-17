// グループ機能の状態とデータ取得を管理するProvider群。
// グループの作成・参加・退出、グループ情報・メンバー・投稿一覧の取得を担当。
// 方針に従い、Supabaseを直接呼ぶ（共有リポジトリ層は作らない）。

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase_client.dart';
import '../../models/app_user.dart';
import '../../models/group.dart';

// グループ詳細画面で1件の投稿を表示するためのビューモデル。
// post_shares・posts・users を結合した表示用データ。
class GroupPost {
  const GroupPost({
    required this.postId,
    required this.videoUrl,
    required this.userName,
    this.userIconUrl,
    required this.createdAt,
  });

  final String postId;
  final String videoUrl;
  final String userName;
  final String? userIconUrl;
  final DateTime createdAt;
}

// 投稿一覧取得の引数（グループ・日付・時間帯）。FutureProvider.family のキー。
class GroupPostsArgs {
  const GroupPostsArgs({
    required this.groupId,
    required this.date,
    required this.hour,
  });

  final String groupId;
  // 日付（時刻は無視し YYYY-MM-DD として扱う）。
  final DateTime date;
  final int hour;

  // post_shares.shared_date（DATE型）に渡す 'YYYY-MM-DD' 文字列。
  String get sharedDate =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is GroupPostsArgs &&
      other.groupId == groupId &&
      other.sharedDate == sharedDate &&
      other.hour == hour;

  @override
  int get hashCode => Object.hash(groupId, sharedDate, hour);
}

// グループ関連のSupabase操作をまとめたサービス。
class GroupService {
  static const _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String get _currentUserId {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('ログインしていません');
    }
    return user.id;
  }

  String _generateInviteCode() {
    final rand = Random.secure();
    return List.generate(6, (_) => _codeChars[rand.nextInt(_codeChars.length)])
        .join();
  }

  // グループを作成し、作成者を自動的にメンバーへ追加する。
  Future<Group> createGroup(String name) async {
    final userId = _currentUserId;

    // 招待コードの重複（UNIQUE違反）に備えて数回リトライする。
    Map<String, dynamic>? inserted;
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        inserted = await supabase
            .from('groups')
            .insert({
              'name': name,
              'invite_code': _generateInviteCode(),
              'owner_id': userId,
            })
            .select()
            .single();
        break;
      } on Exception {
        if (attempt == 4) rethrow;
      }
    }

    final group = Group.fromJson(inserted!);
    await supabase.from('group_members').insert({
      'group_id': group.id,
      'user_id': userId,
    });
    return group;
  }

  // 招待コードからグループを探して参加する。
  Future<Group> joinGroup(String inviteCode) async {
    final userId = _currentUserId;
    final code = inviteCode.trim().toUpperCase();

    final found = await supabase
        .from('groups')
        .select()
        .eq('invite_code', code)
        .maybeSingle();
    if (found == null) {
      throw Exception('招待コードが見つかりません');
    }
    final group = Group.fromJson(found);

    final already = await supabase
        .from('group_members')
        .select('id')
        .eq('group_id', group.id)
        .eq('user_id', userId)
        .maybeSingle();
    if (already != null) {
      throw Exception('すでに参加しています');
    }

    await supabase.from('group_members').insert({
      'group_id': group.id,
      'user_id': userId,
    });
    return group;
  }

  // グループから退出する（自分のメンバー行を削除）。
  Future<void> leaveGroup(String groupId) async {
    await supabase
        .from('group_members')
        .delete()
        .eq('group_id', groupId)
        .eq('user_id', _currentUserId);
  }

  Future<Group> fetchGroup(String groupId) async {
    final json =
        await supabase.from('groups').select().eq('id', groupId).single();
    return Group.fromJson(json);
  }

  Future<List<AppUser>> fetchMembers(String groupId) async {
    final rows = await supabase
        .from('group_members')
        .select('users(id, name, icon_url, created_at)')
        .eq('group_id', groupId)
        .order('joined_at');
    return rows
        .map((row) => AppUser.fromJson(row['users'] as Map<String, dynamic>))
        .toList();
  }

  // 指定グループ・日付・時間帯の投稿一覧を取得する。
  Future<List<GroupPost>> fetchPosts(GroupPostsArgs args) async {
    final rows = await supabase
        .from('post_shares')
        .select(
            'created_at, posts(id, video_url, created_at, users(name, icon_url))')
        .eq('group_id', args.groupId)
        .eq('shared_date', args.sharedDate)
        .eq('shared_hour', args.hour)
        .order('created_at');

    return rows.map((row) {
      final post = row['posts'] as Map<String, dynamic>;
      final user = post['users'] as Map<String, dynamic>?;
      return GroupPost(
        postId: post['id'] as String,
        videoUrl: post['video_url'] as String,
        userName: (user?['name'] as String?) ?? '名無し',
        userIconUrl: user?['icon_url'] as String?,
        createdAt: DateTime.parse(post['created_at'] as String),
      );
    }).toList();
  }
}

final groupServiceProvider = Provider<GroupService>((ref) => GroupService());

// グループ基本情報を取得するProvider。
// autoDispose: 画面を開くたびに最新を取得する（古いキャッシュを残さない）。
final groupProvider =
    FutureProvider.autoDispose.family<Group, String>((ref, groupId) {
  return ref.read(groupServiceProvider).fetchGroup(groupId);
});

// グループのメンバー一覧を取得するProvider。
final groupMembersProvider =
    FutureProvider.autoDispose.family<List<AppUser>, String>((ref, groupId) {
  return ref.read(groupServiceProvider).fetchMembers(groupId);
});

// 指定した日付・時間帯のグループ投稿一覧を取得するProvider。
// autoDispose にすることで、送信後に開き直すと投稿が反映される。
final groupPostsProvider =
    FutureProvider.autoDispose.family<List<GroupPost>, GroupPostsArgs>(
        (ref, args) {
  return ref.read(groupServiceProvider).fetchPosts(args);
});
