// 撮影動画プレビュー用の VideoPlayerController を生成する。
// Web（blob URL）とモバイル（ファイルパス）で生成方法が異なるため、
// 条件付きインポートでプラットフォームごとの実装を切り替える。

export 'video_preview_factory_io.dart'
    if (dart.library.html) 'video_preview_factory_web.dart';
