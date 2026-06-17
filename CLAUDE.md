# プロジェクト概要

42ハッカソン向けの Setlog 風動画共有アプリ。Flutter + Supabase で構築する。

詳細仕様は `docs/` 以下を参照。

---

# コーディング時の必須ルール

コードを書くときは必ず以下を守ること。詳細は [docs/コーディング規約.md](docs/コーディング規約.md) を参照。

## フォルダ構成

```
lib/
├── main.dart
├── core/          # Supabase初期化・ルーティング
├── features/      # 機能単位でフォルダを切る
│   ├── auth/
│   ├── home/
│   ├── group/
│   └── post/
└── models/        # 共通データモデル
```

## コメント規則

- **ファイル先頭**: 必ず1〜2行、そのファイルの責務を日本語で書く
- **クラス・Provider**: 任意、1行で役割を日本語で書く
- **メソッド内**: 基本なし。WHYが分からない箇所のみ
- **行単位のコメント**: 書かない

```dart
// グループ詳細画面。時間・日付移動による投稿フィルタリングUI。
class GroupDetailScreen extends ConsumerWidget {
```

## 状態管理・ルーティング

- 状態管理: **Riverpod**（`flutter_riverpod`）
- ルーティング: **go_router**、全ルートは `core/router.dart` に集約
- 画面内で直接 `Navigator.push` は使わない

## Git・環境変数

- コミットメッセージ: 日本語
- 環境変数は `.env`（`flutter_dotenv` で読み込む）、Gitに上げない

## 命名規則

- ファイル名: `snake_case.dart`
- クラス名: `PascalCase`
- 変数・関数: `camelCase`
- Provider: `camelCase` + `Provider`（例: `groupProvider`）
