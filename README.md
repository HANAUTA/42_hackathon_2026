# Setlog

グループで短い動画（Vlog）を共有するアプリ。Flutter + Supabase で構築。

各自が自分の Supabase プロジェクトを用意し、`.env` に接続情報を貼るだけで動く。

---

## 必要なもの

- Flutter（SDK 3.11.5 以上）… 下の「Flutter のインストール」を参照
- Supabase アカウント（無料・クレジットカード不要）

---

## Flutter のインストール

> すでに Flutter が入っている人はこの章を飛ばしてOK。
> 入っているか確認するには `flutter --version` を実行。

動作確認は **Chrome（Web）** に統一するのがおすすめ。OSの差を気にせず全員同じ手順で動かせる。
（※ カメラ撮影だけは Web だと不安定なことがあるので、必要なら Android 実機で確認）

### Windows の場合

1. [Flutter公式（Windows）](https://docs.flutter.dev/get-started/install/windows) を開く
2. Flutter SDK の zip をダウンロードして展開（例: `C:\src\flutter`）
3. 環境変数 **PATH** に `C:\src\flutter\bin` を追加
4. PowerShell を開き直して `flutter doctor` を実行
5. Git が未インストールなら [Git for Windows](https://git-scm.com/download/win) を入れる

> Android 実機/エミュレータで動かしたい場合のみ Android Studio も入れる。
> **Windows では iOS アプリはビルドできない**（Apple の制約）。Web か Android を使う。

### Mac の場合

1. Homebrew が入っていれば一番楽：

   ```bash
   brew install --cask flutter
   ```

   （Homebrew が無い場合は [Flutter公式（macOS）](https://docs.flutter.dev/get-started/install/macos) から zip を入手して展開し、PATH に `flutter/bin` を追加）
2. ターミナルで `flutter doctor` を実行
3. iOS 実機/シミュレータで動かしたい場合のみ **Xcode** を App Store から入れる

### 共通：セットアップ確認

```bash
flutter doctor
```

緑のチェックが付いていればOK。`[!]` が出ても、使うターゲット（Chrome / Android）に関係する項目だけ解消すれば問題ない。

---

## セットアップ手順

### 1. クローンして依存を取得

```bash
git clone <このリポジトリのURL>
cd 42_hackathon_2026
flutter pub get
```

### 2. Supabase プロジェクトを作成

1. [supabase.com](https://supabase.com) でログイン
2. 「New project」でプロジェクトを作成（リージョンは Tokyo 推奨）
3. パスワードは任意（後で使わない）

### 3. データベースを構築（SQL一発）

1. Supabase ダッシュボード左メニューの **SQL Editor** を開く
2. [supabase/schema.sql](supabase/schema.sql) の中身を全部コピーして貼り付け
3. **Run** で実行

これだけで以下が全部できる：

- テーブル（users / groups / group_members / posts / post_shares）
- RLS（行レベルセキュリティ）ポリシー
- Storage バケット（videos / icons）とアクセス権

> ⚠️ `schema.sql` は再実行すると既存データを削除して作り直す。最初の1回だけ実行すること。

### 4. メール確認をOFFにする（重要・忘れがち）

Supabase はデフォルトで新規登録時にメール確認が必須。これがONのままだと**サインアップしてもログインできず詰まる**。

1. ダッシュボード左メニュー **Authentication** → **Sign In / Providers**（または **Settings**）
2. **Email** の項目で **Confirm email** を **OFF** にする

> これはSQLでは設定できないコンソール操作。必ずやること。

### 5. `.env` を作成して接続情報を貼る

```bash
cp .env.example .env
```

`.env` を開いて、Supabase の接続情報を貼る：

```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

接続情報の場所：ダッシュボード左下 **Project Settings** → **API**

- `SUPABASE_URL` = **Project URL**
- `SUPABASE_ANON_KEY` = **anon public** key

> `.env` は Git に上げない（`.gitignore` 済み）。

### 6. 起動

```bash
# Web（開発中の動作確認に便利）
flutter run -d chrome

# Android 実機
flutter run
```

---

## フォルダ構成

```
lib/
├── main.dart        # エントリーポイント
├── core/            # Supabase初期化・ルーティング
├── features/        # 機能単位（auth / home / group / post）
└── models/          # 共通データモデル

supabase/
├── schema.sql       # DB構築スクリプト（これを1回流す）
└── seed.sql         # テスト用ダミーデータ（任意）

docs/                # 仕様・設計ドキュメント
```

---

## テストデータを入れたい場合（任意）

[supabase/seed.sql](supabase/seed.sql) を SQL Editor に貼って実行するとダミーデータが入る。

---

## よくあるトラブル

| 症状 | 原因と対処 |
|------|-----------|
| 起動時にエラー画面が出る | `.env` の URL / key が未設定 or 間違い。手順5を確認 |
| サインアップ後にログインできない | メール確認がONのまま。手順4を確認 |
| 動画アップロードに失敗する | `schema.sql` を実行したか確認（Storageバケットが必要） |

---

## 開発ルール

コーディング規約は [docs/コーディング規約.md](docs/コーディング規約.md) を参照。
