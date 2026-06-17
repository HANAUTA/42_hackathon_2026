// 画面遷移の共通ヘルパー。
// 「戻る」操作を全画面で同じ挙動に揃えるための部品。

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

extension AppNavigation on BuildContext {
  // 戻れる履歴があれば前の画面へ、無ければホームへ遷移する。
  // どの画面から来ても安全に「戻る」を実現するために使う。
  void backOrHome() {
    if (canPop()) {
      pop();
    } else {
      go('/home');
    }
  }
}
