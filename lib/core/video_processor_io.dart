// モバイル（Android/iOS）向け動画変換。FFmpegで720p縦型mp4に統一する。

import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

Future<ProcessedVideo> processVideo(XFile input) async {
  final dir = await path_provider.getTemporaryDirectory();
  final outputPath =
      '${dir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.mp4';

  // -y: 上書き許可
  // -i: 入力
  // -vf: 720x1280（縦型）に収まるようリサイズ＋余白は黒パディング
  // -c:v libx264 -preset fast -crf 23: h264エンコード（速度と品質のバランス）
  // -c:a aac -b:a 128k: 音声をAACに統一
  // -movflags +faststart: ストリーミング再生を高速化
  final command = '-y -i "${input.path}" '
      '-vf "scale=720:1280:force_original_aspect_ratio=decrease,'
      'pad=720:1280:(ow-iw)/2:(oh-ih)/2:black" '
      '-c:v libx264 -preset fast -crf 23 '
      '-c:a aac -b:a 128k '
      '-movflags +faststart '
      '"$outputPath"';

  final session = await FFmpegKit.execute(command);
  final returnCode = await session.getReturnCode();

  if (!ReturnCode.isSuccess(returnCode)) {
    final logs = await session.getAllLogsAsString();
    throw Exception('動画の変換に失敗しました: $logs');
  }

  final bytes = await File(outputPath).readAsBytes();

  // 一時ファイルを削除
  try {
    await File(outputPath).delete();
  } catch (_) {}

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
