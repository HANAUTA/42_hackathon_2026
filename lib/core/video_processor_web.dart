// Web向け動画変換。ブラウザ内のffmpeg.wasmで720p縦型mp4に統一する。
// 実体は web/ffmpeg_helper.js（window.processVideoWeb）をjs_interopで呼ぶ。

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:camera/camera.dart';

@JS('processVideoWeb')
external JSPromise<JSUint8Array> _processVideoWeb(JSUint8Array input);

Future<ProcessedVideo> processVideo(XFile input) async {
  final inputBytes = await input.readAsBytes();
  // ignore: avoid_print
  print('[ffmpeg-web/dart] 変換要求: 入力 ${inputBytes.length} bytes');
  try {
    final result = await _processVideoWeb(inputBytes.toJS).toDart;
    final bytes = result.toDart;
    // ignore: avoid_print
    print('[ffmpeg-web/dart] 変換成功: 出力 ${bytes.length} bytes');
    return ProcessedVideo(
      bytes: bytes,
      extension: 'mp4',
      mimeType: 'video/mp4',
    );
  } catch (e) {
    // ignore: avoid_print
    print('[ffmpeg-web/dart] 変換失敗: $e');
    rethrow;
  }
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
