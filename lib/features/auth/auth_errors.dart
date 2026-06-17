// 認証エラーをユーザー向けの日本語メッセージに変換する共通処理。
// 画面には生の例外を出さず、参加者が安心できる文言を返す。
// 新しいエラーパターンが見つかったら、ここに1か所追加するだけでよい。

import 'package:supabase_flutter/supabase_flutter.dart';

// 認証系の例外を、画面表示用の日本語メッセージに変換する。
String authErrorMessage(Object error) {
  if (error is AuthException) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return 'メールアドレスまたはパスワードが正しくありません。';
    }
    if (message.contains('already registered') ||
        message.contains('user already')) {
      return 'このメールアドレスは既に登録されています。ログインしてください。';
    }
    if (message.contains('email not confirmed')) {
      return 'メールアドレスの確認が完了していません。';
    }
    if (message.contains('rate limit') ||
        message.contains('over_email_send')) {
      return '試行回数が多すぎます。少し時間をおいて再度お試しください。';
    }
    if (message.contains('password')) {
      return 'パスワードは6文字以上で入力してください。';
    }
    if (message.contains('email')) {
      return 'メールアドレスの形式が正しくありません。';
    }
    return '認証に失敗しました。入力内容を確認してください。';
  }

  // ネットワーク系（dart:io を使わず文字列で判定し、Web/モバイル両対応にする）。
  final text = error.toString().toLowerCase();
  if (text.contains('socket') ||
      text.contains('network') ||
      text.contains('connection') ||
      text.contains('failed host')) {
    return '通信エラーが発生しました。ネットワーク接続を確認してください。';
  }

  return '予期しないエラーが発生しました。もう一度お試しください。';
}
