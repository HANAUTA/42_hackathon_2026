# Setlog（セットログ）

グループで短い動画を共有するスマホアプリです。
**Flutter** と **Supabase** で動いています。

---

## 全体の流れ

```
【事前に自分で準備】 VS Code・Chrome・GitHub アカウント
        ↓
【当日みんなで】    Flutter → clone → .env → 起動！
        ↓
【好きなタイミングで】Claude Code 設定 ／ スマホ配布設定
```

### 🎯 最初のゴール：全員がアプリを起動できること

1. **Flutter を入れる**（当日みんなで）
2. **チームのリポジトリを作ってクローンする**（当日みんなで）
3. **アプリを起動する**（配られた値をコピペするだけ） ← ✅ ここまで来たらゴール！

### 🛠 そのあと（グループごとに好きなタイミングで）

4. **Claude Code を設定する**（配られた API キーを使う）
5. **開発の流れを知る**（ブランチ → 開発 → マージ → スマホに届く）

> 💡 開発は **Chrome（ブラウザ）** で行います。Windows でも Mac でも同じです。
> スマホでの確認は `main` に push すると**自動で Android 端末に届く**仕組みです（設定方法は後述）。

---

## 事前に準備しておくもの

当日スムーズに始めるために、**以下の3つを事前に用意**しておいてください。

### ✅ VS Code（エディタ）

1. [VS Code 公式ダウンロードページ](https://code.visualstudio.com/) を開く
2. 自分のパソコン（Windows / Mac）に合わせてダウンロード → インストール

> 💡 VS Code を開いて左の四角いアイコン（拡張機能）から **「Flutter」** を検索してインストールしておくと開発が楽になります。

### ✅ Chrome（ブラウザ）

開発中のアプリを Chrome で表示して確認します。
入っていない人は [google.com/chrome](https://www.google.com/chrome/) からインストール。

### ✅ GitHub アカウント

コードの保存・共有に使います。
アカウントが無い人は [github.com](https://github.com) で作っておいてください。

---

## ステップ1：Flutter を入れる

> すでに入っている人は飛ばしてOK。確認方法 ↓
>
> ```bash
> flutter --version
> ```
>
> バージョンが出れば入っています。

### 🪟 Windows の人

PowerShell を開いて、**1行ずつコピペして実行**してください。

```powershell
# 1. Flutter SDK をダウンロード・展開する（C:\src に配置）
mkdir C:\src -ErrorAction SilentlyContinue
cd C:\src
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.32.4-stable.zip" -OutFile flutter.zip
Expand-Archive -Path flutter.zip -DestinationPath . -Force
Remove-Item flutter.zip
```

```powershell
# 2. PATH に追加する（今のターミナルだけ有効）
$env:Path += ";C:\src\flutter\bin"
```

```powershell
# 3. 確認
flutter doctor
```

> ⚠️ **PowerShell を閉じると PATH が消えます。** 永続化するには：
>
> 1. Windows キーを押して **「環境変数」** と検索 → 「環境変数を編集」を開く
> 2. 「ユーザー環境変数」の **Path** をダブルクリック
> 3. **「新規」** → `C:\src\flutter\bin` を追加 → OK
> 4. PowerShell を**開き直して** `flutter --version` で確認

### 🍎 Mac の人

ターミナルを開いて、**1行ずつコピペして実行**してください。

```bash
# 1. Homebrew で Flutter をインストール
brew install --cask flutter
```

```bash
# 2. 確認
flutter doctor
```

> Homebrew が無い人は、先にこれを実行：
>
> ```bash
> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
> ```

### 入れ終わったら

```bash
flutter doctor
```

✅ いくつか緑のチェックが出ればOK。
`[!]` マークが出ても、Chrome が使えていれば問題ありません。

---

## ステップ2：チームのリポジトリを作ってクローンする

テンプレートのコードをコピーして、**チーム専用のリポジトリ**を作ります。

### 2-1. git が入っているか確認する

```bash
git --version
```

バージョンが出ればOK。出ない人は入れます。

- 🍎 Mac：`brew install git`
- 🪟 Windows：[git公式ページ](https://git-scm.com/download/win) からインストール

### 2-2. 代表者がリポジトリを作る（チームで1人だけ）

> **この作業は代表者1人だけ**です。他のメンバーは 2-3 まで待ってください。

#### ① GitHub に空のリポジトリを作る

1. [github.com](https://github.com) にログイン
2. 右上の **「+」** → **「New repository」** をクリック
3. 以下を入力する

| 項目 | 入れる値 |
|---|---|
| Repository name | チーム名など（例：`team-alpha-setlog`） |
| Public / Private | **Public** |
| Initialize this repository | **チェックしない**（空のまま） |

4. **「Create repository」** をクリック
5. 表示されるリポジトリの URL をメモしておく

#### ② テンプレートをコピーして push する

ターミナルで **1行ずつ順番に** コピペして実行します。
**最後の行の URL だけ**、①で作った自分のリポジトリの URL に置きかえてください。

```bash
git clone -b yunchol https://github.com/HANAUTA/42_hackathon_2026.git
```

```bash
cd 42_hackathon_2026
```

```bash
rm -rf .git
```

```bash
git init
```

```bash
git add .
```

```bash
git commit -m "Initial commit"
```

```bash
git branch -M main
```

```bash
git remote add origin https://github.com/あなたのユーザー名/リポジトリ名.git
```

```bash
git push -u origin main
```

> 🔑 push 時にログインを求められたら、GitHub のユーザー名と
> **パスワードの代わりにアクセストークン（PAT）** を入力します。

#### ③ チームメンバーを招待する

1. GitHub でリポジトリを開く → **「Settings」** → **「Collaborators」**
2. **「Add people」** → メンバーの GitHub ユーザー名で招待
3. **リポジトリの URL をチーム全員に共有**する

### 2-3. メンバー全員がクローンする

代表者からリポジトリの URL と招待を受け取ったら：

1. GitHub の通知 or メールから **招待を承認**する
2. ターミナルで実行（URL は代表者から共有されたもの）：

```bash
git clone https://github.com/代表者のユーザー名/リポジトリ名.git
```

```bash
cd リポジトリ名
```

```bash
flutter pub get
```

> 💡 代表者も、最初に `git clone` した元のフォルダを消して改めて `git clone` し直すと安全です。

---

## ステップ3：アプリを起動する

### 3-1. 設定ファイルを作る

```bash
cp .env.example .env
```

### 3-2. 配られた接続情報を貼る

運営から **Supabase の URL と Key** が配られます。
`.env` ファイルを VS Code で開いて、配られた値を貼り付けてください。

```
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...（長い文字列）
```

> ⚠️ **ブラウザのアドレスバーの URL ではありません！** 配られたものをそのまま貼ってください。
>
> 🔑 `.env` には大事な情報が入るので、GitHub には上がりません（設定済み）。

### 3-3. 起動！

```bash
flutter run -d chrome
```

Chrome が立ち上がってアプリが表示されたら成功です🎉

**ここまでで「全員がアプリを起動できる」ゴール達成です！** 🏁

---

## ステップ4：Claude Code を設定する

> グループごとに好きなタイミングで進めてください。

**Claude Code** は、AI がコードを書くのを手伝ってくれる道具です。

### 4-1. Claude Code を入れる

```bash
npm install -g @anthropic-ai/claude-code
```

> Node.js が入っていない人は [nodejs.org](https://nodejs.org) からインストール
> （🍎 Mac は `brew install node` でもOK）。

### 4-2. API キーを設定する

🍎 **Mac**

```bash
export ANTHROPIC_API_KEY=（配られたキーを貼る）
```

🪟 **Windows**（PowerShell）

```powershell
$env:ANTHROPIC_API_KEY="（配られたキーを貼る）"
```

> 💡 ターミナルを閉じると消えます。永続化したい人は Mac なら `~/.zshrc` に `export ...` を追加。

### 4-3. 確認

```bash
claude
```

会話できれば成功です🎉

---

## ステップ5：開発の流れ

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
| `flutter` コマンドが見つからない | インストール or PATH 設定を見直す（ステップ1） |
| `git clone` でアクセスできない | GitHub の招待を承認したか確認（ステップ2） |
| 起動したらエラー画面が出る | `.env` の URL・Key が正しいか確認（ステップ3） |
| ログインできない | 運営に連絡 |
| `claude` コマンドが見つからない | Node.js と Claude Code のインストール確認（ステップ4） |
| push したのにスマホに届かない | 5〜8分待つ / Actions の Secrets 設定を確認 |
| ビルドが失敗する（赤いバツ） | Secret の Name の打ち間違いが多い。[手順書](docs/GitHub_Actions設定手順.md)を再確認 |

---

## もっと知りたい人へ

- フォルダ構成や開発ルール → [docs/コーディング規約.md](docs/コーディング規約.md)
- テスト用ダミーデータ → [supabase/seed.sql](supabase/seed.sql) を SQL Editor で実行
- スマホ自動配布の設定 → [docs/GitHub_Actions設定手順.md](docs/GitHub_Actions設定手順.md)
- 運営向けセットアップ → [docs/運営セットアップ.md](docs/運営セットアップ.md)
