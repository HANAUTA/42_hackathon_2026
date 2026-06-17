// 動画URLからキャッシュ済みの VideoPlayerController を生成するファクトリ。
// モバイルはディスクキャッシュ（flutter_cache_manager）で同じ動画の再取得を防ぎ、
// Web はファイル再生に非対応のためネットワーク再生にフォールバックする。
// 条件付きインポートでプラットフォームごとの実装を切り替える。

export 'cached_video_io.dart'
    if (dart.library.html) 'cached_video_web.dart';
