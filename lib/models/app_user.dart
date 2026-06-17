// ユーザー情報のデータモデル。Supabaseのusersテーブルと対応。
// ※ DartのUser名はSupabase Authと衝突しやすいため AppUser とする。

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? iconUrl;
  final DateTime createdAt;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_url': iconUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
