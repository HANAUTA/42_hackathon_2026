// Android/iOS用スタブ。kIsWeb=false の環境では呼ばれない。
Future<String> enumerateCamerasWebImpl() {
  throw UnsupportedError('Web only');
}
