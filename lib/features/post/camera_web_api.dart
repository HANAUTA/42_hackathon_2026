// カメラ列挙APIの条件付きexport。
// Web: dart:html が使える環境 → camera_web_impl.dart（実装）
// その他: camera_web_stub.dart（スタブ）
export 'camera_web_stub.dart'
    if (dart.library.html) 'camera_web_impl.dart';
