// Web 向け実装。ファイル再生に非対応のためネットワーク再生する。
// 同じURLの再取得はブラウザのHTTPキャッシュに任せる。

import 'package:video_player/video_player.dart';

// ネットワーク再生用のコントローラを返す。
Future<VideoPlayerController> createCachedVideoController(String url) async {
  return VideoPlayerController.networkUrl(Uri.parse(url));
}

// Webでは先読みは行わない（ブラウザキャッシュに任せる）。
Future<void> prefetchVideo(String url) async {}
