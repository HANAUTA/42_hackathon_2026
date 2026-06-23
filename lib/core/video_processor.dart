// 動画を720p縦型mp4に変換するプロセッサ。Web/モバイルで実装を切り替える。

export 'video_processor_io.dart'
    if (dart.library.html) 'video_processor_web.dart';
