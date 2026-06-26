# Setlog（セットログ）

グループで短い動画を共有するスマホアプリです。
**Flutter** と **Supabase** で動いています。

---

## 全体の流れ

```
【事前に自分で準備】 VS Code・Chrome・Git・GitHub アカウント
        ↓
【当日みんなで】    Flutter → clone → .env → 起動！
        ↓
【動いたら】        必須課題 → 自由課題に挑戦
        ↓
【好きなタイミングで】Claude Code 設定 ／ スマホ配布設定
```

> 💡 開発は **Chrome（ブラウザ）** で行います。Windows でも Mac でも同じです。
> スマホでの確認は `main` に push すると**自動で Android 端末に届く**仕組みです（後述）。

---

## 📚 まずはこれを読む

| やること | ドキュメント |
|---|---|
| ① 当日までに用意するもの | [事前準備ガイド](docs/事前準備ガイド.md) |
| ② アプリを起動するまで | [環境構築（当日手順）](docs/環境構築.md) |
| ③ 全員でやる課題 | [必須課題](docs/必須課題.md) |
| ④ 慣れてきたら挑戦 | [自由課題](docs/自由課題.md) |

> 🎯 **最初のゴールは「全員がアプリを起動できること」**。
> [環境構築](docs/環境構築.md) の手順どおりに進めれば Chrome でアプリが立ち上がります。

---

## 開発の流れ

起動できたら、いよいよ開発です。

```
① ブランチを作る → ② Chrome で開発 → ③ push → ④ main にマージ → ⑤ スマホに届く
```

> **大事なルール：`main` に直接コミットしない。**
> 自分のブランチで作業 → main にマージ、の流れで進めます。

### ① ブランチを作る

```bash
git checkout -b 自分の名前
```

例：`git checkout -b taro`

### ② Chrome で開発する

```bash
flutter run -d chrome
```

コードを変えるとブラウザが自動で更新されます（hot reload）。

### ③ 自分のブランチに push する

```bash
git add .
git commit -m "変更内容をここに書く"
git push -u origin 自分のブランチ名
```

> 2回目以降は `git push` だけでOK。この時点ではスマホには届きません。

### ④ main にマージする（ここでスマホに届く！）

```bash
git checkout main
git pull
git merge 自分のブランチ名
git push
```

> **`git push` した瞬間に自動ビルドが始まります。** 約5〜8分後にスマホに届きます。
>
> ⚠️ マージでエラー（コンフリクト）が出たら、無理に進めず運営に相談してください。

マージ後は自分のブランチに戻って作業を続けられます。

```bash
git checkout 自分のブランチ名
```

### ⑤ スマホで確認する

貸し出し端末の **Firebase App Tester** を開いて最新版をインストールします。

### まとめ：1サイクル

```bash
git checkout taro              # 自分のブランチで作業
flutter run -d chrome          # Chrome で開発

git add .
git commit -m "○○を修正"
git push                       # 自分のブランチに push

git checkout main
git pull
git merge taro
git push                       # ← ここで自動ビルドが走る！

git checkout taro              # 戻って続きの作業
```

> 💡 Chrome で確認できること・できないこと
>
> | 確認項目 | Chrome | スマホ実機 |
> |---|---|---|
> | 画面の見た目・操作 | ◎ | ◎ |
> | ログイン・データ保存 | ◎ | ◎ |
> | カメラ撮影 | △（制限あり） | ◎ |
> | 動画の向き・表示 | △ | ◎ |

---

## 📱 スマホ自動配布について

`main` に push すると **GitHub Actions** が自動で APK をビルドし、貸し出し Android 端末に届きます。

この仕組みを使うには、**グループごとに GitHub Actions の環境変数（Secrets）を設定**する必要があります。
好きなタイミングで、以下の手順書を見ながら設定してください。

👉 **[GitHub Actions 設定手順](docs/GitHub_Actions設定手順.md)**

> 📱 **Android 端末は運営が貸し出します。**
> Firebase App Tester のインストール・メールアドレスの登録は運営が済ませてあります。
> 参加者側で端末の準備は不要です。

---

## 困ったときは

| こんな症状 | こうする |
|---|---|
| `flutter` コマンドが見つからない | インストール or PATH 設定を見直す（[環境構築](docs/環境構築.md) ステップ1） |
| `git clone` でアクセスできない | GitHub の招待を承認したか確認（[環境構築](docs/環境構築.md) ステップ2） |
| 起動したらエラー画面が出る | `.env` の URL・Key が正しいか確認（[環境構築](docs/環境構築.md) ステップ3） |
| ログインできない | 運営に連絡 |
| `claude` コマンドが見つからない | Node.js と Claude Code のインストール確認（[環境構築](docs/環境構築.md) ステップ4） |
| push したのにスマホに届かない | 5〜8分待つ / Actions の Secrets 設定を確認 |
| ビルドが失敗する（赤いバツ） | Secret の Name の打ち間違いが多い。[手順書](docs/GitHub_Actions設定手順.md)を再確認 |

---

## もっと知りたい人へ

- フォルダ構成や開発ルール → [コーディング規約](docs/コーディング規約.md)
- データベースの構造 → [データベース設計](docs/データベース設計.md)
- テスト用ダミーデータ → [supabase/seed.sql](supabase/seed.sql) を SQL Editor で実行
- スマホ自動配布の設定 → [GitHub Actions 設定手順](docs/GitHub_Actions設定手順.md)
