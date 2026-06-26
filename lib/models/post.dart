// 投稿のデータモデル。Supabaseのpostsテーブルと対応。
// 共有先グループは post_shares（PostShare）で別管理する。

class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.videoUrl,
    required this.createdAt,
    this.needsFlip = false,
    this.platform = 'mobile',
  });

  final String id;
  final String userId;
  final String videoUrl;
  final DateTime createdAt;
  // ファイル自体が上下逆に記録された動画(Android前面カメラ等)の補正フラグ。
  final bool needsFlip;
  // 投稿元プラットフォーム('web' / 'mobile')。同じプラットフォームでのみ取得できる。
  final String platform;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      videoUrl: json['video_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      needsFlip: json['needs_flip'] as bool? ?? false,
      platform: json['platform'] as String? ?? 'mobile',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'video_url': videoUrl,
      'created_at': createdAt.toIso8601String(),
      'needs_flip': needsFlip,
      'platform': platform,
    };
  }
}
