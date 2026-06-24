# GitHub Actions 設定手順（スマホ自動配布）

`main` ブランチに push すると、自動で APK がビルドされて Android 端末に届く仕組みです。
**グループごとに1回だけ**設定すればOKです。

---

## 全体像

```
main に push → GitHub Actions が APK をビルド → Firebase App Distribution → 貸し出し端末に届く
```

---

## 設定手順

### 1. GitHub リポジトリの Secrets を登録する

**設定場所の開き方：**

1. GitHub でチームのリポジトリを開く
2. 上のタブから **「Settings」** をクリック
3. 左メニューの **「Secrets and variables」** → **「Actions」** をクリック
4. **「New repository secret」** ボタンをクリック

**登録する4つの Secret：**

1つずつ「Name」と「Secret」を入力して **「Add secret」** を押す、を4回繰り返します。

| Name（この通りに入力） | Secret（貼り付ける値） |
|---|---|
| `SUPABASE_URL` | `.env` に貼ったのと同じ **Supabase の URL**（`https://xxxxxxxx.supabase.co`） |
| `SUPABASE_ANON_KEY` | `.env` に貼ったのと同じ **anon key**（`eyJhbGciOi...` の長い文字列） |
| `FIREBASE_APP_ID` | 運営から配られる Firebase の **アプリID** |
| `FIREBASE_SERVICE_ACCOUNT` | 運営から配られる Firebase の **サービスアカウント JSON** |

> ⚠️ **Name は大文字・アンダースコアで、上の表の通りに正確に入力**してください。1文字でも違うとビルドが失敗します。
>
> ⚠️ Secret には**値だけ**を貼ります。`SUPABASE_URL=` のような `=` は要りません。
>
> ⚠️ `FIREBASE_SERVICE_ACCOUNT` は JSON ファイルの**中身をまるごとコピー**して貼ります（`{` から `}` まで全部）。

4つ登録し終わったら、Secrets 一覧に4つ並んでいることを確認してください。

### 2. テスト push してビルドを走らせる

グループの誰か1人がやればOKです。

```bash
# main ブランチにいることを確認
git checkout main
git pull

# 何か小さな変更を加える（READMEに1行足すだけでOK）
echo "" >> README.md

# コミットして push
git add README.md
git commit -m "ビルドテスト"
git push
```

push できたら、**GitHub のリポジトリページ** → 上のタブから **「Actions」** をクリック。

```
┌─────────────────────────────────────────┐
│  ✅ ビルドテスト                          │
│     Build & Distribute APK              │
│     🟡 In progress...                   │  ← 黄色い丸 = ビルド中
└─────────────────────────────────────────┘
```

**黄色い丸が回っていればビルド開始！** 完了まで **約5〜8分** かかります。

> ❌ 赤いバツ（失敗）になったら → クリックしてエラーログを確認。
> 一番多い原因は **Secret の Name の打ち間違い**です。

### 3. 貸し出し端末で確認する

ビルドが完了（緑のチェック ✅）したら：

1. 貸し出し Android 端末で **Firebase App Tester** を開く
2. 最新のビルドが表示される → **「ダウンロード」** → **「インストール」**
3. アプリが起動できれば成功！

> リリースノートに **コミットメッセージ**（例：「自動ビルド - ビルドテスト」）が表示されるので、
> どの push のビルドか分かります。

---

## 以降の使い方

`main` にマージ → push するたびに、同じ流れで自動的にスマホに届きます。
詳しい開発フローは README のステップ4「開発の流れ」を参照してください。
