// 撮影画面。表示時にカメラを自動起動し、動画を撮影する。
// イン/アウトカメラ切替・タイマー設定も担当。撮影後は送信画面へ。
// ※ STEP1ではプレースホルダー。Lane D（投稿）で本実装する。

import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: '撮影画面',
      links: [
        (label: '撮影完了 → 送信画面へ', path: '/send'),
      ],
    );
  }
}
