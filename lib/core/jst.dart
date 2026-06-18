// 日本時間（JST = UTC+9）のユーティリティ。端末タイムゾーンに依存しない日時処理。

DateTime jstNow() => DateTime.now().toUtc().add(const Duration(hours: 9));

String jstDateString(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
