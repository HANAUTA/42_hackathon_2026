// モバイル（Android/iOS）向け動画パススルー。
// ffmpeg-kit の Maven 依存が廃止のため、カメラ出力をそのままバイト列として返す。
// ステッカーの焼き付けは行わない（表示オーバーレイのみ）。

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../models/sticker_overlay.dart';

Future<ProcessedVideo> processVideo(
  XFile input, {
  List<StickerOverlay> stickers = const [],
  bool needsFlip = false,
}) async {
  debugPrint('[video-io] パススルー開始: ${input.path}');
  final file = File(input.path);
  final bytes = await file.readAsBytes();
  debugPrint('[video-io] ✅ 読み込み完了: ${bytes.length} bytes');
  return ProcessedVideo(bytes: bytes, extension: 'mp4', mimeType: 'video/mp4');
}

class ProcessedVideo {
  const ProcessedVideo({
    required this.bytes,
    required this.extension,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String extension;
  final String mimeType;
}
