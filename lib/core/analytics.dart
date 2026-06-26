// アナリティクスイベントをSupabaseに記録するユーティリティ。

import 'package:flutter/foundation.dart';

import 'supabase_client.dart';

class Analytics {
  Analytics._();

  static Future<void> log(String eventName,
      [Map<String, dynamic>? properties]) async {
    final userId = supabase.auth.currentUser?.id;
    try {
      await supabase.from('analytics_events').insert({
        'user_id': userId,
        'event_name': eventName,
        'properties': properties,
      });
    } catch (e) {
      debugPrint('[analytics] 記録失敗: $e');
    }
  }
}
