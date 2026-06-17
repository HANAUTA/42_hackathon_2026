// Web向けのプレビューコントローラ生成。
// XFile のパスは blob URL なので networkUrl として再生する。

import 'package:video_player/video_player.dart';

VideoPlayerController createPreviewController(String path) =>
    VideoPlayerController.networkUrl(Uri.parse(path));
