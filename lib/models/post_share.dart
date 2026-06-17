// 投稿の共有先のデータモデル。Supabaseのpost_sharesテーブルと対応。
// 1投稿を複数グループへ共有する構造。
// 「1グループ・同じ日・同じ時間帯は1回まで」の制限を sharedDate + sharedHour で管理する。

class PostShare {
  const PostShare({
    required this.id,
    required this.postId,
    required this.groupId,
    required this.sharedDate,
    required this.sharedHour,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String groupId;
  // 共有した日付（日本時間）。sharedHour と組み合わせて重複投稿を防ぐ。
  final DateTime sharedDate;
  // 共有した時間帯（0〜23）。
  final int sharedHour;
  final DateTime createdAt;

  factory PostShare.fromJson(Map<String, dynamic> json) {
    return PostShare(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      groupId: json['group_id'] as String,
      sharedDate: DateTime.parse(json['shared_date'] as String),
      sharedHour: json['shared_hour'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'group_id': groupId,
      // DATE型カラムには 'YYYY-MM-DD' 形式で渡す。
      'shared_date':
          sharedDate.toIso8601String().split('T').first,
      'shared_hour': sharedHour,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
