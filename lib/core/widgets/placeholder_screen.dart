// STEP1の骨組み用プレースホルダー画面。
// 各featureの担当者が本物の画面に差し替えるまでの仮表示。
// 遷移先ボタンを並べて、ルーティングが繋がっているか確認できるようにする。

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 画面名と遷移ボタンを表示する仮画面。
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.links = const [],
  });

  final String title;
  // (ボタン表示名, 遷移先パス) のリスト。
  final List<({String label, String path})> links;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            for (final link in links)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  onPressed: () => context.go(link.path),
                  child: Text(link.label),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
