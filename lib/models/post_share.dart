// 投稿の共有先のデータモデル。Supabaseのpost_sharesテーブルと対応。
// 1投稿を複数グループへ共有する構造。1グループ1時間1回の制限を sharedHour で管理する。

class PostShare {
  const PostShare({
    required this.id,
    required this.postId,
    required this.groupId,
    required this.sharedHour,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String groupId;
  // 共有した時間帯（0〜23）。同一グループ・同一時間帯の重複投稿を防ぐ判定に使う。
  final int sharedHour;
  final DateTime createdAt;

  factory PostShare.fromJson(Map<String, dynamic> json) {
    return PostShare(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      groupId: json['group_id'] as String,
      sharedHour: json['shared_hour'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'group_id': groupId,
      'shared_hour': sharedHour,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
