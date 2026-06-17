// アプリのエントリーポイント。
// Supabase初期化 → Riverpodのスコープ設定 → ルーター付きアプリ起動を担当。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initSupabase();
    runApp(const ProviderScope(child: SetlogApp()));
  } catch (e, st) {
    // 初期化に失敗したら原因を画面に表示する（真っ白を防ぐ）。
    runApp(_StartupErrorApp(error: '$e\n\n$st'));
  }
}

// 起動失敗時に原因を表示する画面。
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              '起動エラー:\n\n$error',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}

// アプリのルートWidget。
class SetlogApp extends StatelessWidget {
  const SetlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Setlog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
