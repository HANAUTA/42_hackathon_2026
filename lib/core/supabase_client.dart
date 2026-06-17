// Supabaseの初期化処理を担当。
// .env から接続情報を読み込み、アプリ起動時に一度だけ呼ぶ。

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabaseを初期化する。main()から起動時に呼び出す。
Future<void> initSupabase() async {
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    // 旧名は anon key。新しいSupabaseでは publishable key と呼ぶ（値は同じ枠）。
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
}

// アプリ全体から使うSupabaseクライアントへのショートカット。
final supabase = Supabase.instance.client;
