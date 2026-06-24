// Web専用: camera_helper.js の enumerateCamerasWeb() を呼ぶ実装。
// dart:js_interop はこのファイルにのみ閉じ込める。

import 'dart:js_interop';

@JS('enumerateCamerasWeb')
external JSPromise<JSString> _enumerateCamerasWebJS();

Future<String> enumerateCamerasWebImpl() async {
  final result = await _enumerateCamerasWebJS().toDart;
  return result.toDart;
}
