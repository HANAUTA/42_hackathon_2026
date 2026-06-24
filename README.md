# Setlog（セットログ）

グループで短い動画を共有するスマホアプリです。
このアプリは **Flutter**（アプリを作る道具）と **Supabase**（データを保存する場所）で動いています。

このページの通りに上から順番に進めれば、自分のパソコンでアプリを動かせます。
**焦らず1ステップずつ**進めてください。

---

## 全体の流れ（先に地図を見ておこう）

準備は大きく **2つのフェーズ** に分かれます。

### 🎯 まずのゴール：全員がアプリを起動できること

これが **最初の最優先目標** です。まずはここまでを全員でそろえます。

0. **VS Code を入れる**（エディタの準備）
1. **Flutter を入れる**（アプリを動かす道具の準備）
2. **GitHub からこのアプリをダウンロードする**（配られたリポジトリを取ってくる）
3. **Supabase を作ってアプリを起動する**（無料・各自で作成） ← ✅ ここまで来たら全員ゴール！

### 🛠 その後の準備：開発の道具をそろえる

アプリが起動できた人から、開発を進めるための道具を準備します。

4. **Claude Code を設定する**（配られたAPIキーを使う）
5. **スマホで確認できるようにする**（アプリを入れるだけ）

> 💡 開発は **Chrome（ブラウザ）** で行います。
> WindowsでもMacでも同じやり方でできるので、まずはこれで進めましょう。
> スマホでの確認は、コードを push すると**自動でAndroid端末に届く**仕組みになっています。
>
> ⏱ **ステップ0〜3（アプリ起動）を最優先**で進めてください。
> ステップ4・5は、アプリが起動できてから取りかかればOKです。

---

## ステップ０：エディタを用意する（こだわりがなければ VS Code 推奨）

このあと、ファイルの中身を見たり編集したりします（例：ステップ4の `.env`）。
そのために **エディタ**（コードを書くためのアプリ）が必要です。

> **こだわりがなければ VS Code（ブイエス・コード）がおすすめです。**
> 無料で、WindowsでもMacでも使えて、このアプリの開発でもよく使われています。

### まだ入れていない人へ

1. [VS Code 公式ダウンロードページ](https://code.visualstudio.com/) を開く
2. 自分のパソコン（Windows / Mac）に合わせてダウンロードして、インストールする
3. インストールが終わったら VS Code を開く

> 💡 **おすすめ設定（任意）**
> VS Code を開いて左側の四角いアイコン（拡張機能）から **「Flutter」** を検索してインストールしておくと、
> このアプリの開発がぐっと楽になります（コードの補完やエラー表示が効くようになります）。

すでに使い慣れたエディタがある人は、それを使ってもOKです。

---

## ステップ1：Flutter を入れる

> すでに入っている人は飛ばしてOK。
> 確認するにはターミナル（Macは「ターミナル」、Windowsは「PowerShell」）で
> 次を打ってバージョンが出れば入っています。
>
> ```bash
> flutter --version
> ```

### 🪟 Windows の人

1. [Flutter公式インストールページ（Windows）](https://docs.flutter.dev/get-started/install/windows) を開く
2. ページの指示に従って Flutter をダウンロードし、`C:\src\flutter` などに展開する
3. 展開した中の `flutter\bin` フォルダを、Windowsの「環境変数 PATH」に追加する
   （やり方が分からなければ「Windows PATH 追加 方法」で検索）
4. **PowerShellを開き直して** `flutter doctor` を打つ

### 🍎 Mac の人

1. ターミナルを開いて、次をコピペして実行する（Homebrewが必要です）

   ```bash
   brew install --cask flutter
   ```

   ※ Homebrew が無い人は [Flutter公式インストールページ（Mac）](https://docs.flutter.dev/get-started/install/macos) を見てください
2. `flutter doctor` を打つ

### 入れ終わったら確認

ターミナルで次を打ちます。

```bash
flutter doctor
```

✅ いくつか緑のチェックが出ればOKです。
`[!]` マークが出ても、いまは気にしなくて大丈夫（Chromeが使えれば進めます）。

---

## ステップ2：GitHub からこのアプリをダウンロードする

アプリのコードは **GitHub**（コードを保管・共有する場所）に置いてあります。
当日 **リポジトリのURL** が配られるので、それを使って自分のパソコンに持ってきます。

### 2-1. git が入っているか確認する

ターミナルで次を打ちます。

```bash
git --version
```

バージョンが出ればOK。出ない人は入れます。

- 🍎 Mac：`brew install git`
- 🪟 Windows：[git公式ページ](https://git-scm.com/download/win) からインストール

### 2-2. GitHub にログインできるようにする

配られたリポジトリにアクセスするには **GitHubアカウント** が必要なことがあります。

1. アカウントが無い人は [github.com](https://github.com) で作る
2. 配られたリポジトリに **招待（invitation）が届いていたら承認** しておく
   （GitHubの通知 or メールから「Accept invitation」を押す）

### 2-3. ダウンロードする

ターミナルで順番に打ちます。
`<このリポジトリのURL>` は **配られたURL** に置きかえてください。

```bash
git clone <このリポジトリのURL>
cd 42_hackathon_2026
flutter pub get
```

- `git clone` … アプリのコードを自分のパソコンに持ってくる
- `cd` … そのフォルダの中に移動する
- `flutter pub get` … アプリが必要とする部品をまとめて取ってくる

> 🔑 クローン時に GitHub のログインを求められたら、アカウントのユーザー名と
> **パスワードの代わりにアクセストークン（PAT）** を入力します。
> 求められない場合は気にしなくてOKです。

---

## ステップ3：Supabase（データベース）を作る

アプリのデータ（ユーザー・グループ・動画など）は **Supabase** に保存されます。
**各自で自分用の Supabase プロジェクトを作って**、そこに接続します（無料です）。

### 3-1. Supabase のアカウントを作る

1. [supabase.com](https://supabase.com) を開く
2. **「Start your project」** をクリック
3. GitHub アカウントでログインする（一番かんたん）

### 3-2. プロジェクトを作る

1. ログインしたら **「New project」** をクリック
2. 以下を入力する

| 項目 | 入れる値 |
|---|---|
| Name | 何でもOK（例：`setlog`） |
| Database Password | 好きなパスワード（あとで使わないが必須） |
| Region | **Northeast Asia (Tokyo)** を選ぶ |

3. **「Create new project」** をクリック
4. 1〜2分待つとプロジェクトが立ち上がる

### 3-3. テーブルを作る（SQL を実行する）

プロジェクトができたら、アプリが使うテーブル（データの入れ物）を作ります。

1. Supabase ダッシュボードの左メニューから **「SQL Editor」** をクリック
2. このリポジトリの `supabase/schema.sql` の**中身を全部コピー**して、エディタに貼り付ける
3. **「Run」** をクリック
4. 「Success」が出ればOK

> 💡 `schema.sql` は VS Code で開いてコピーするのが楽です。

### 3-4. メール確認をオフにする

初期設定ではユーザー登録時に確認メールが飛びますが、開発中は邪魔なのでオフにします。

1. 左メニュー → **Authentication** → **Providers**
2. **Email** をクリック
3. **「Confirm email」** を **オフ** にする
4. **「Save」** をクリック

### 3-5. URL と Key を確認する（ここが大事！）

`.env` に貼る2つの値を確認します。**場所が分かりづらい**ので、この通りに進めてください。

1. 左メニュー → **Project Settings**（歯車アイコン、一番下のほう）
2. **「API」** をクリック

すると以下の2つが表示されます。

```
┌───────────────────────────────────────────────┐
│  Project URL                                  │
│  https://xxxxxxxx.supabase.co    ← これが URL │
│                                               │
│  Project API keys                             │
│  anon  public                                 │
│  eyJhbGciOi...長い文字列...      ← これが Key │
└───────────────────────────────────────────────┘
```

> ⚠️ **「Project URL」の下にある `https://xxxxxxxx.supabase.co`** をコピーしてください。
> ブラウザのアドレスバーの URL（`https://supabase.com/dashboard/...`）ではありません！

> ⚠️ Key は **`anon` `public`** と書いてある方です。`service_role` `secret` の方ではありません。

### 3-6. 設定ファイルを作って値を貼る

ターミナルで次を打つと、設定ファイルの雛形がコピーされます。

```bash
cp .env.example .env
```

できた `.env` ファイルをエディタ（VS Code など）で開き、3-5 で確認した値を貼ります。

```
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...（長い文字列）
```

> 🔑 `.env` には大事な情報が入るので、GitHub には上げません（設定済みなので気にしなくてOK）。

### 3-7. 起動！

```bash
flutter run -d chrome
```

Chromeが立ち上がってアプリが表示されたら成功です🎉

**ここまでで「全員がアプリを起動できる」という最初のゴールは達成です！** 🏁
このあとは、開発を進めるための道具をそろえていきます。

---

## ステップ4：Claude Code を設定する（アプリが起動できたら）

> ⚠️ これは **ステップ3でアプリが起動できた人から** 進めてください。
> まだ起動できていない人は、先にステップ0〜3を優先しましょう。

**Claude Code** は、AIがコードを書くのを手伝ってくれる開発の道具です。
ハッカソン用に **APIキー** が配られるので、それを設定して使えるようにします。

### 4-1. Claude Code を入れる

ターミナルで次を打ちます（Node.js が必要です）。

```bash
npm install -g @anthropic-ai/claude-code
```

> Node.js が入っていない人は [nodejs.org](https://nodejs.org) からインストール
> （または 🍎 Mac は `brew install node`）。

### 4-2. 配られた APIキー を設定する

配られた APIキー を環境変数に設定します。`（配られたキーを貼る）` の部分を置きかえてください。

🍎 **Mac の人**（ターミナル）

```bash
export ANTHROPIC_API_KEY=（配られたキーを貼る）
```

🪟 **Windows の人**（PowerShell）

```powershell
$env:ANTHROPIC_API_KEY="（配られたキーを貼る）"
```

> 💡 この設定は **ターミナルを閉じると消えます**。
> 毎回打つのが面倒な人は、シェルの設定ファイル（Mac は `~/.zshrc` など）に
> 上の `export ...` の行を書いておくと、次回から自動で読み込まれます。

### 4-3. 起動して確認する

アプリのフォルダの中で次を打ちます。

```bash
cd 42_hackathon_2026
claude
```

Claude Code が立ち上がって会話できれば成功です🎉
`> こんにちは` のように打って返事が返ってくればOKです。

---

## ステップ5：スマホで確認できるようにする（Android）

このアプリは、コードを GitHub に push すると**自動でAPKがビルドされ、スマホに届く**仕組みになっています。
Android 端末があれば、事前にアプリを1つ入れておくだけで受け取れます。

> 📱 **iPhoneの人は**、スマホでの確認は Web版（Chrome / Safari）で行います。
> APKの自動配布は Android 限定です。

### 5-1. Firebase App Tester を入れる

1. Android 端末で **Google Play** を開く
2. **「Firebase App Tester」** を検索してインストールする

### 5-2. 招待メールを承認する

1. 運営から招待メールが届く（Firebase App Distribution から送信されます）
2. メール内のリンクをタップして承認する

これで準備完了です。
以降、誰かが `main` ブランチに push するたびに、自動で最新版のアプリが届きます。
通知が来たら Firebase App Tester を開いてインストールするだけです。

### 5-3. （運営向け）GitHub Actions の Secrets を設定する

> この設定は**運営が1回だけ**行えばOKです。参加者は何もしなくて大丈夫です。

自動ビルド・配布が動くためには、GitHub リポジトリに **4つの Secrets** を登録する必要があります。

**設定場所：** GitHub リポジトリ → Settings → Secrets and variables → Actions → **New repository secret**

| Secret 名 | 値の説明 | どこで手に入る？ |
|---|---|---|
| `SUPABASE_URL` | Supabase プロジェクトの URL | Supabase ダッシュボード → Settings → API → Project URL |
| `SUPABASE_ANON_KEY` | Supabase の匿名キー | Supabase ダッシュボード → Settings → API → anon public |
| `FIREBASE_APP_ID` | Firebase の Android アプリ ID | Firebase コンソール → プロジェクト設定 → 全般 → アプリID |
| `FIREBASE_SERVICE_ACCOUNT` | Firebase のサービスアカウント JSON（**中身を丸ごと**貼る） | Firebase コンソール → プロジェクト設定 → サービスアカウント → 新しい秘密鍵を生成 |

> ⚠️ `FIREBASE_SERVICE_ACCOUNT` は、ダウンロードした JSON ファイルの**中身をそのままコピー**して貼り付けてください（`{` から `}` まで全部）。`SUPABASE_URL=` のような `=` 形式ではなく、**値だけ**を貼ります。

> 詳しい手順は [docs/運営セットアップ.md](docs/運営セットアップ.md) を参照してください。

---

## ステップ6：開発の流れ（当日はこうやって進める）

全体の流れはこうです。

```
① ブランチを作る → ② Chrome で開発 → ③ push する → ④ main にマージ → ⑤ 自動でスマホに届く
```

> **大事なルール：`main` ブランチに直接コミットしない。**
> 必ず自分のブランチを作って、そこで作業 → main にマージする流れで進めます。
> main にマージされた瞬間に GitHub Actions が走り、APK が自動ビルドされてスマホに届きます。

### ① ブランチを作る（最初に1回）

作業を始めるとき、まず自分のブランチを作ります。

```bash
git checkout -b 自分の名前や機能名
```

例：

```bash
git checkout -b taro
```

> 💡 `git checkout -b` は「新しいブランチを作って、そこに移動する」コマンドです。
> 一度作ったブランチに戻るときは `git checkout taro`（`-b` なし）でOKです。

### ② Chrome で開発する（メインの作業場）

```bash
flutter run -d chrome
```

コードを変更すると、ブラウザが自動で更新されます（hot reload）。
**画面の見た目や操作のほとんどはこれで確認できます。**

### ③ 自分のブランチに push する

ひと区切りついたら、自分のブランチを GitHub に push します。

```bash
git add .
git commit -m "変更内容をここに書く"
git push -u origin 自分のブランチ名
```

例：

```bash
git add .
git commit -m "ログイン画面を修正"
git push -u origin taro
```

> 💡 2回目以降の push は `git push` だけでOKです（`-u origin ...` は初回だけ）。
> この時点ではまだスマホには届きません。**自分のブランチに push しただけ**です。

### ④ main にマージする（ここで自動ビルドが走る！）

自分のブランチの変更を main に合流させます。

```bash
git checkout main
git pull
git merge 自分のブランチ名
git push
```

例：

```bash
git checkout main
git pull
git merge taro
git push
```

> **`git push` した瞬間に GitHub Actions が自動で動き出します。**
> APK のビルドが始まり、約5〜8分後にスマホに届きます。

> ⚠️ **マージでエラー（コンフリクト）が出たら**、無理に進めず運営に相談してください。

マージしたら自分のブランチに戻って、続きの作業ができます。

```bash
git checkout 自分のブランチ名
```

### ⑤ スマホで確認する

Firebase App Tester アプリを開いて、最新版をインストールします。
**カメラ・動画まわりなど、Chrome では確認しづらい機能はここでチェック**してください。

> APK のリリースノートに **コミットメッセージ** が表示されるので、どの変更のビルドか分かります。

### まとめ：よくある1サイクル

```bash
# 1. 自分のブランチで作業
git checkout taro
flutter run -d chrome        # Chrome で開発

# 2. 変更を push
git add .
git commit -m "○○を修正"
git push

# 3. main にマージ → 自動でスマホに届く
git checkout main
git pull
git merge taro
git push                      # ← ここで Actions が走る！

# 4. 自分のブランチに戻って続きの作業
git checkout taro
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

## 困ったときは

| こんな症状 | こうする |
|------------|----------|
| 起動したらエラー画面が出る | `.env` の URL・キーが間違っていないか確認（ステップ3） |
| 新規登録したのにログインできない | 運営に連絡（Supabase側のメール確認設定の問題） |
| 動画のアップロードに失敗する | 運営に連絡（Supabase側のテーブル設定の問題） |
| `flutter` コマンドが見つからない | Flutterのインストール or PATH設定を見直す（ステップ1） |
| `git clone` でアクセスできない | GitHubの招待を承認したか確認（ステップ2-2） |
| `claude` コマンドが見つからない | Claude Code のインストールを見直す（ステップ4-1） |
| Claude Code が認証エラーになる | `ANTHROPIC_API_KEY` を設定したか確認（ステップ4-2） |
| push したのにスマホに届かない | 5〜8分待つ。それでも届かなければ運営に連絡 |
| スマホにアプリをインストールできない | Firebase App Tester が入っているか・招待を承認したか確認（ステップ5） |

---

## もっと知りたい人へ

- フォルダの構成や開発のルール → [docs/コーディング規約.md](docs/コーディング規約.md)
- テスト用のダミーデータを入れたい → [supabase/seed.sql](supabase/seed.sql) を SQL Editor で実行
- 運営向け：自動ビルド・配布の仕組みのセットアップ → [docs/運営セットアップ.md](docs/運営セットアップ.md)
