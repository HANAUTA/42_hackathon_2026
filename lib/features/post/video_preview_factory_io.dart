// モバイル（dart:io 利用可）向けのプレビューコントローラ生成。
// XFile のパスはローカルファイルパスなので File から再生する。

import 'dart:io';

import 'package:video_player/video_player.dart';

VideoPlayerController createPreviewController(String path) =>
    VideoPlayerController.file(File(path));
