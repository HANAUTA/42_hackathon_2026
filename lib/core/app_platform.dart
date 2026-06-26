// 動画の取得元プラットフォーム判定。Web動画はWebのみ・スマホ動画はスマホのみで
// 取得できるよう棲み分けるため、投稿の保存値・取得フィルタに使う識別子を一元管理する。

import 'package:flutter/foundation.dart';

// この端末のプラットフォーム識別子。posts.platform への保存と取得フィルタに使う。
const String currentPlatform = kIsWeb ? 'web' : 'mobile';
