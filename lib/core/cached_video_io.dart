// モバイル（iOS/Android）向け実装。flutter_cache_manager で動画をディスクに
// キャッシュし、2回目以降はローカルファイルから再生する（Storageへの再取得を防ぐ）。

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

// URLの動画をキャッシュ（無ければダウンロード）し、ファイル再生用のコントローラを返す。
Future<VideoPlayerController> createCachedVideoController(String url) async {
  final file = await DefaultCacheManager().getSingleFile(url);
  return VideoPlayerController.file(file);
}

// 動画を裏でダウンロードしてキャッシュに載せておく（先読み用）。失敗は無視する。
Future<void> prefetchVideo(String url) async {
  try {
    await DefaultCacheManager().getSingleFile(url);
  } catch (_) {
    // 先読みは失敗しても本再生に影響しないため握りつぶす。
  }
}
