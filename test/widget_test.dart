// 基盤の動作確認用テスト。
// 本格的なテストは各featureの担当者が追加する。

import 'package:flutter_test/flutter_test.dart';
import 'package:setlog_app/models/app_user.dart';

void main() {
  test('AppUser.fromJson でSupabaseのレスポンスをパースできる', () {
    final user = AppUser.fromJson({
      'id': 'user-1',
      'name': 'たろう',
      'icon_url': null,
      'created_at': '2026-06-17T11:40:00.000Z',
    });

    expect(user.id, 'user-1');
    expect(user.name, 'たろう');
    expect(user.iconUrl, isNull);
    expect(user.createdAt.year, 2026);
  });
}
