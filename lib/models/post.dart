// 投稿のデータモデル。Supabaseのpostsテーブルと対応。
// 共有先グループは post_shares（PostShare）で別管理する。

class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.videoUrl,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String videoUrl;
  final DateTime createdAt;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      videoUrl: json['video_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'video_url': videoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
