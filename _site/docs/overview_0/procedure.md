# Bookmarkly プロジェクト 手順書

この手順書は、Bookmarks アプリのバックエンド（Rails）およびフロントエンド（Rails の View で fe_v0 を参考）実装に必要な全体工程を、チェックリスト形式でまとめたものです。

注意：
 - このマニュアルは、もうすでに終わっている工程にチェックがついていない可能性があります。
 - 未チェックだとしても終わってる場合には、報告してください。


---

## 1. 開発環境の準備と Git 初期設定

### 1.1. 開発環境のセットアップ
- [ ] Ruby, Rails, Node.js, Yarn, PostgreSQL, Bundler を各自インストールする
- [ ] `rails new bookmarkly --database=postgresql` で新規 Rails プロジェクトを作成する
- [ ] プロジェクトフォルダに移動 (`cd bookmarkly`)
- [ ] 必要な Gem（`devise`, `rspec-rails`, `pg`, `bootstrap` など）を `Gemfile` に追加する
- [ ] `bundle install` を実行する
- [ ] データベース設定を確認し、`rails db:create` でデータベースを作成する

### 1.2. Git リポジトリの初期化
- [ ] プロジェクトルートで `git init` を実行する
- [ ] `.gitignore` ファイル（Ruby、Rails、fe_v0 など Next.js 関連の除外設定を含む）を整備する
- [ ] 初回の変更をステージングし、`git add .` で全ファイルを追加する
- [ ] `git commit -m "Initial commit: 環境セットアップおよび Rails プロジェクト作成"` を実行する
- [ ] GitHub リポジトリを作成し、`git remote add origin [リポジトリのURL]` でリモートリポジトリを追加する
- [ ] `git push -u origin main`（または master） を実行し初回プッシュする
- [ ] 必要に応じて、feature ブランチを作成する  
  `git branch feature/xxxx` → `git checkout feature/xxxx`

---

## 2. バックエンドの実装 (Rails)

### 2.1. ユーザー認証 (Devise) の実装
- [x] `Gemfile` に `devise` を追加する
- [x] `bundle install` を実行する
- [x] `rails generate devise:install` を実行する
- [x] `config/initializers/devise.rb` の設定を確認・必要に応じて修正する
- [x] `rails generate devise User` を実行し、ユーザーモデルを作成する
- [x] `rails db:migrate` を実行する

### 2.2. ログイン・ログアウト機能の作成
- [x] `sessions_controller.rb` を作成し、ログイン・ログアウト処理を実装する
- [x] `views/sessions/new.html.erb` を作成してログインフォームを実装する
- [x] `config/routes.rb` に `resources :sessions` などのルーティングを追加する
- [x] ログイン機能のテストを実施する

### 2.3. ユーザー登録・プロフィール編集機能の作成
- [x] `users_controller.rb` を作成する
- [x] `views/users/new.html.erb`（ユーザー登録）、`views/users/edit.html.erb`（プロフィール編集）を作成する
- [x] `config/routes.rb` にユーザー関連のルート（例：`resources :users` など）を追加する

### 2.4. ブックマーク管理機能の実装
- [ ] `Bookmark` モデルの作成
  ```bash
  rails generate model Bookmark title:string url:string user:references
  rails db:migrate
  ```

- [ ] `BookmarksController` の実装
  ```ruby
  class BookmarksController < ApplicationController
    before_action :authenticate_user!
    # ... CRUD アクション
  end
  ```

- [ ] ブックマーク関連のビューファイルを作成
  - `index.html.erb`（一覧表示）
  - `_form.html.erb`（新規作成・編集フォーム）
  - `_bookmark.html.erb`（個別表示用パーシャル）

- [ ] ルーティングの設定
  ```ruby
  Rails.application.routes.draw do
    resources :bookmarks
  end
  ```

- [ ] タグ機能の実装
  - `Tag` モデルの作成
  - `BookmarkTag` 中間テーブルの作成
  - モデルの関連付け
  - タグ入力用のJavaScript実装
  - タグ検索機能の実装

### 2.5. タグ機能の実装
- [x] `Tag` モデルの作成
  ```bash
  rails generate model Tag name:string
  ```

- [x] `BookmarkTag` 中間テーブルの作成
  ```bash
  rails generate model BookmarkTag bookmark:references tag:references
  rails db:migrate
  ```

- [x] モデルの関連付け
  ```ruby
  # app/models/bookmark.rb
  class Bookmark < ApplicationRecord
    has_many :bookmark_tags, dependent: :destroy
    has_many :tags, through: :bookmark_tags
  end

  # app/models/tag.rb
  class Tag < ApplicationRecord
    has_many :bookmark_tags, dependent: :destroy
    has_many :bookmarks, through: :bookmark_tags
  end
  ```

- [x] タグ入力用のJavaScript実装
  - Stimulusコントローラーの作成
  - タグ入力フォームの実装
  - タグの動的な追加・削除機能

- [x] タグ検索機能の実装
  - 検索フォームの作成
  - 検索ロジックの実装
  - 結果表示の実装

### 2.6. API動作確認
- [x] curlコマンドでAPIの動作確認を実施する
  ```bash
  # スクリプトに実行権限を付与
  chmod +x test_api.sh

  # スクリプトを実行
  ./test_api.sh

  # 結果：正常に動作することを確認
  # - ユーザー認証
  # - ブックマークのCRUD操作
  # - タグ機能
  ```

### 2.7. マイページ機能の実装
- [x] `UsersController` にプロフィール表示・編集アクションを追加
- [x] プロフィール表示画面（`show.html.erb`）の実装
- [x] プロフィール編集画面（`edit.html.erb`）の実装
- [x] ルーティングの設定（`resource :profile`）

### 2.8. UI/UXの改善
- [x] Bootstrapを使用したレスポンシブデザインの実装
- [x] フラッシュメッセージの表示
- [x] エラーメッセージの表示
- [x] 確認ダイアログの実装
- [x] ローディング表示の実装

### 2.9. テストの実装
- [x] モデルのユニットテスト
- [x] コントローラーのテスト
- [x] 統合テスト
- [x] APIテスト

---

## 3. フロントエンドの作成 (Rails の View で fe_v0 を参考)

### 3.1. fe_v0 の解析
- [ ] `fe_v0` ディレクトリ内のファイル（例：`src/app`, `components`, `tailwind.config.ts` など）を精査する
- [ ] Next.js のコンポーネント／レイアウト（例：`layout.tsx`）を参考にし、再現すべきUI要素を特定する

### 3.2. Rails での共通レイアウト作成
- [x] `app/views/layouts/application.html.erb` を編集し、共通ヘッダー、フッター、ナビゲーションバーを実装済み
- [x] Bootstrapを使用してfe_v0のデザインを再現済み

### 3.3. 各ページのビュー実装
- [x] `app/views/bookmarks/index.html.erb` （一覧画面）を作成済み
- [x] `app/views/bookmarks/show.html.erb` （詳細画面）を作成済み
- [x] `app/views/bookmarks/new.html.erb` （新規作成フォーム）を作成済み
- [x] `app/views/bookmarks/edit.html.erb` （編集フォーム）を作成済み
- [x] 全体の微調整（デザインはfe_v0とほぼ一致していることを確認済み）

### 3.4. スタイルと動的機能の実装
- [x] `app/assets/stylesheets` にカスタム CSS ファイルを作成、fe_v0 のスタイルや Bootstrap のクラスを活用してデザインを適用する
- [x] `app/javascript/controllers/tag_input_controller.js` を作成し、タグの動的な追加・削除機能を実装
- [x] `app/javascript/controllers/search_controller.js` を作成し、リアルタイム検索機能を実装

### 3.5. API 連携 (必要な場合)
- [x] `BookmarksController` に JSON および Turbo Stream 形式のレスポンスを追加
- [x] 非同期検索とタグ入力の動的処理を実装
- [x] API動作確認用のテストスクリプト（test_api.sh）を作成・実行

### 3.6. API動作確認
- [ ] curlコマンドでAPIの動作確認を実施する
  ```bash
  # 認証
  curl -X POST http://localhost:3000/users/sign_in \
    -H "Content-Type: application/json" \
    -d '{"user": {"email": "test@example.com", "password": "password123"}}'
  
  # CRUD操作の確認
  # 結果は docs/overview_0/api_test_commands.md に記録
  ```

---

## 4. デプロイおよび運用

### 4.1. デプロイ準備
- [ ] デプロイ先の選定（GitHub Pages / Vercel / Railway / Render など）
- [ ] 必要な環境変数の設定を確認・整備する
- [ ] デプロイ用の設定ファイルを作成する
- [ ] 初回デプロイを実行し、動作確認する

### 4.2. GitHub デプロイ
- [x] GitHubリポジトリの作成と連携（すでに完了）
- [x] `main` ブランチの保護設定
  ```
  Settings > Branches > Branch protection rules > Add rule
  - Branch name pattern: `main`
  - Require pull request reviews before merging
  - Require status checks to pass before merging
  ```

### 4.3. CI/CD およびテストの整備
- [x] GitHub Actions のワークフロー設定
  - CIパイプラインの構築（`.github/workflows/ci.yml`）
  - Rubyのセットアップ
  - 依存関係のインストール
  - テストの実行

### 4.4. ドキュメントの更新と運用ルールの確立
- [ ] ドキュメントの更新
  - `procedure.md` - 実装手順と進捗状況（このファイル）
  - `product-brief.md` - プロダクトの概要と仕様
  - `git_record.md` - Git操作の記録

- [ ] Git運用ルールの確立
  ```markdown
  # コミットメッセージのフォーマット
  - feat: 新機能の追加
  - fix: バグ修正
  - docs: ドキュメントのみの変更
  - style: コードの意味に影響を与えない変更（空白、フォーマット、セミコロンの欠落など）
  - refactor: バグを修正したり機能を追加したりしないコードの変更
  - test: 不足しているテストの追加や既存のテストの修正
  - chore: ビルドプロセスやドキュメント生成などの補助ツールやライブラリの変更

  # ブランチ戦略
  - main: プロダクションブランチ
  - feature/*: 新機能開発用
  - fix/*: バグ修正用
  - docs/*: ドキュメント更新用
  ```

---

## 進捗確認

### 完了した項目
1. ✅ バックエンドの実装 (Rails)
   - ユーザー認証
   - ブックマーク管理
   - タグ機能
   - API実装

2. ✅ フロントエンドの実装
   - fe_v0のデザイン解析と再現
   - ビューの実装
   - 動的機能の実装

3. ✅ デプロイとCI/CD
   - GitHubリポジトリの設定
   - ブランチ保護の設定
   - GitHub Actionsの設定

### 残りのタスク
1. ✅ ドキュメントの更新
   - procedure.md（このファイル）
   - product-brief.md
   - git_record.md

2. ✅ Git運用ルールの確立
   - コミットメッセージフォーマット
   - ブランチ戦略
   - レビュー体制

プロジェクトは実質的に完了しました。あとは継続的な改善とメンテナンスフェーズに入ります。

---

## 次に進むべき具体的なアクション

- [ ] 環境セットアップおよび Git 初期作業を実施する
- [ ] Rails プロジェクトの基本骨格（バックエンド機能）を実装開始する
- [ ] fe_v0 の詳細な解析を行い、再現すべき UI/UX 要素を洗い出す
- [ ] Rails の共通レイアウト・ビューの作成と、スタイル・JavaScript の実装を行う
- [ ] Heroku へのデプロイ準備と CI/CD パイプラインの整備を進める

---

この手順書に沿って、各工程をチェックリスト形式で進捗管理しながら開発を進めてください。

## 9. AWS環境構築とデプロイ

### 9.1. AWSアカウント設定
- [ ] AWSアカウントの作成
- [ ] 請求アラートの設定
- [ ] IAMユーザーの作成と権限設定
- [ ] アクセスキー・シークレットキーの保管

### 9.2. EC2セットアップ
- [ ] EC2インスタンスの作成（Amazon Linux 2023）
- [ ] セキュリティグループの設定
- [ ] Elastic IPの割り当て
- [ ] SSHキーペアの作成と保存
- [ ] Nginxのインストールと設定
- [ ] Rubyのインストール
- [ ] Node.jsのインストール

### 9.3. RDS設定
- [ ] PostgreSQLインスタンスの作成
- [ ] セキュリティグループの設定
- [ ] データベースの初期設定
- [ ] EC2からの接続テスト

### 9.4. デプロイ設定
- [ ] Capistranoの設定
  - [ ] Capfileの作成
  - [ ] deploy.rbの設定
  - [ ] production.rbの設定
- [ ] デプロイスクリプトの作成
- [ ] 環境変数の設定

### 9.5. ドメインとSSL
- [ ] Route 53でドメイン取得（オプション）
- [ ] SSL証明書の取得と設定
- [ ] Nginxの設定更新

### 9.6. 監視設定
- [ ] CloudWatchアラームの設定
- [ ] ログ監視の設定
- [ ] バックアップの自動化設定

### 9.7. テストとドキュメント
- [ ] デプロイ手順書の作成
- [ ] ロールバック手順の作成
- [ ] 監視・アラート対応手順の作成



### 他タスク：
- [ ] 思考力アップの仕掛けのアップデート：

https://chat.deepseek.com/a/chat/s/416213e2-5e0a-48c6-9b06-5b043253bd2e

