// 投稿（撮影・送信）の状態とロジックを管理するProvider群。
// 撮影した動画の保持・参加中グループ取得・1時間制限の判定・
// Storageアップロード〜posts/post_shares書き込みを担当する。

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/jst.dart';
import '../../core/supabase_client.dart';
import '../../models/group.dart';

// 撮影直後の動画ファイルを送信画面へ受け渡すための保持先。
// 取り消し・送信完了時に null に戻す。
class RecordedVideoNotifier extends Notifier<XFile?> {
  @override
  XFile? build() => null;

  void set(XFile? video) => state = video;
  void clear() => state = null;
}

final recordedVideoProvider =
    NotifierProvider<RecordedVideoNotifier, XFile?>(RecordedVideoNotifier.new);

// 送信先選択に必要なデータ（参加中グループ + 今この時間帯に投稿済みのグループID）。
class SendTargets {
  const SendTargets({required this.groups, required this.postedGroupIds});

  final List<Group> groups;
  // 今日・現在の時間帯に既に投稿済みのグループID（グレーアウト対象）。
  final Set<String> postedGroupIds;
}

// 送信画面で参加中グループと投稿済み状況をまとめて取得するProvider。
final sendTargetsProvider = FutureProvider.autoDispose<SendTargets>((ref) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) {
    return const SendTargets(groups: [], postedGroupIds: {});
  }

  final memberRows = await supabase
      .from('group_members')
      .select('groups(*)')
      .eq('user_id', userId);

  final groups = <Group>[
    for (final row in memberRows)
      if (row['groups'] != null)
        Group.fromJson(row['groups'] as Map<String, dynamic>),
  ];

  if (groups.isEmpty) {
    return const SendTargets(groups: [], postedGroupIds: {});
  }

  final now = jstNow();
  final today = jstDateString(now);
  final hour = now.hour;

  final shareRows = await supabase
      .from('post_shares')
      .select('group_id, posts!inner(user_id)')
      .eq('posts.user_id', userId)
      .eq('shared_date', today)
      .eq('shared_hour', hour)
      .inFilter('group_id', [for (final g in groups) g.id]);

  final postedGroupIds = <String>{
    for (final row in shareRows) row['group_id'] as String,
  };

  return SendTargets(groups: groups, postedGroupIds: postedGroupIds);
});

// 撮影・送信の操作（送信処理）を提供するProvider。
final postControllerProvider = Provider<PostController>((ref) {
  return PostController(ref);
});

// 動画アップロード〜posts/post_shares作成を行う送信処理。
class PostController {
  PostController(this._ref);

  final Ref _ref;

  // 動画を videos バケットへアップロードし、posts と post_shares を作成する。
  // postsは常に作成され「自分のログ」に表示される。
  // groupIdsを指定するとそのグループにも共有する（複数同時送信に対応）。
  Future<void> send({
    required XFile video,
    required List<String> groupIds,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('ログインが必要です');
    }

    final bytes = await video.readAsBytes();
    final ext = _extension(video);
    final now = jstNow();
    final path =
        '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await supabase.storage.from('videos').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: video.mimeType ?? 'video/$ext'),
        );
    final videoUrl = supabase.storage.from('videos').getPublicUrl(path);

    final post = await supabase
        .from('posts')
        .insert({'user_id': userId, 'video_url': videoUrl})
        .select()
        .single();
    final postId = post['id'] as String;

    if (groupIds.isNotEmpty) {
      await supabase.from('post_shares').insert([
        for (final groupId in groupIds)
          {
            'post_id': postId,
            'group_id': groupId,
            'user_id': userId,
            'shared_date': jstDateString(now),
            'shared_hour': now.hour,
          },
      ]);
    }

    _ref.read(recordedVideoProvider.notifier).clear();
  }
}


// 動画ファイルの拡張子を求める。Webは webm、その他は mp4 を既定とする。
String _extension(XFile video) {
  final name = video.name;
  final dot = name.lastIndexOf('.');
  if (dot != -1 && dot < name.length - 1) {
    return name.substring(dot + 1).toLowerCase();
  }
  final mime = video.mimeType ?? '';
  if (mime.contains('webm')) return 'webm';
  if (mime.contains('mp4')) return 'mp4';
  return 'mp4';
}
