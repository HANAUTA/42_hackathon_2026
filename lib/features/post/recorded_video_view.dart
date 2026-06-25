// 撮影動画を統一した向き(横向き)で表示する共通ウィジェット。
// 撮影元プラットフォーム(recordedOnWeb)に基づいて回転・反転を補正する。

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class RecordedVideoView extends StatelessWidget {
  const RecordedVideoView({
    super.key,
    required this.controller,
    this.needsFlip = false,
    this.recordedOnWeb = false,
  });

  final VideoPlayerController controller;
  final bool needsFlip;
  final bool recordedOnWeb;

  @override
  Widget build(BuildContext context) {
    final quarterTurns = ((recordedOnWeb ? 1 : 3) + (needsFlip ? 2 : 0)) % 4;

    return FittedBox(
      fit: BoxFit.cover,
      child: Transform.scale(
        scaleX: recordedOnWeb ? -1 : 1,
        scaleY: 1,
        child: RotatedBox(
          quarterTurns: quarterTurns,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }
}
