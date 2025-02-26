---
name: "docs/overview_0/project-structure.md"
title: "プロジェクト構造概要 (Project Structure)"
description: "Bookmark app - ディレクトリ構成など"
---
以下は、**Bookmarkly**プロジェクトにおける**docs/overview_0/project-structure.md** の内容です。こちらは、アプリケーションのディレクトリ構成や、主要なファイル・ディレクトリの役割についての説明を行います。

---

# docs/overview_0/project-structure.md

## 1. ディレクトリ構成

以下は、**Bookmarkly**アプリケーションの基本的なディレクトリ構成です。シンプルな構成にして、初心者でも理解しやすいようにしています。

```
app/
├── controllers/         # コントローラー（Railsアプリのロジック）
│   ├── bookmarks_controller.rb
│   ├── sessions_controller.rb
│   └── users_controller.rb
├── models/              # モデル（データベースとのやりとり）
│   ├── bookmark.rb
│   ├── user.rb
│   └── tag.rb
├── views/               # ビュー（ユーザーに表示される画面）
│   ├── bookmarks/       # ブックマーク関連のビュー
│   ├── sessions/        # ログイン・登録関連のビュー
│   └── users/           # ユーザー関連のビュー
├── helpers/             # ビューで使うヘルパーメソッド
│   └── application_helper.rb
├── assets/              # スタイルシート、JavaScript、画像など
│   ├── stylesheets/
│   ├── javascripts/
│   └── images/
├── config/              # 設定ファイル
│   ├── routes.rb        # アプリケーションのルーティング設定
│   └── database.yml     # データベース接続設定
├── db/                  # データベース関連
│   ├── migrate/         # マイグレーションファイル
│   └── schema.rb        # データベースのスキーマ
├── lib/                 # ユーティリティ関数や外部APIとの連携
├── public/              # 公開される静的ファイル
├── test/                 # テストファイル（RSpecなど）
│   ├── controllers/
│   ├── models/
│   └── integration/
├── config.ru            # Rack設定ファイル
├── Gemfile              # 使用するgemのリスト
└── README.md            # プロジェクトの説明ファイル
```

---

## 2. 主要ファイルの役割

### 2.1. `app/controllers/`
- **bookmarks_controller.rb**  
  - ブックマークのCRUD（作成、読み取り、更新、削除）処理を担当。
  - ユーザーがブックマークを登録したり、検索したり、削除したりするロジックを実装します。

- **sessions_controller.rb**  
  - ログイン機能を実装します。ユーザーがログイン、ログアウトするための処理を記述。

- **users_controller.rb**  
  - ユーザーの登録・更新・削除・プロフィール管理などを担当します。

### 2.2. `app/models/`
- **bookmark.rb**  
  - ブックマークのデータモデル。`title`（タイトル）、`url`（URL）、`description`（概要）、`tags`（タグ）などを格納します。

- **user.rb**  
  - ユーザーのデータモデル。`email`（メールアドレス）、`password_digest`（パスワードのハッシュ）、`name`（名前）などを格納します。Deviseで認証を管理。

- **tag.rb**  
  - タグモデル。各ブックマークにタグを付け、検索機能で使用します。

### 2.3. `app/views/`
- **bookmarks/**  
  - ブックマーク関連のビュー（フォーム、一覧表示など）を管理。

- **sessions/**  
  - ログイン、登録、パスワードリセットなどの画面ビュー。

- **users/**  
  - ユーザーのプロフィールページや設定画面など。

### 2.4. `config/routes.rb`
- アプリケーションのルーティング設定。どのURLにアクセスした際に、どのコントローラー・アクションを呼び出すかを定義。

```ruby
Rails.application.routes.draw do
  root 'bookmarks#index'
  resources :bookmarks
  resource :session, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create, :show, :edit, :update]
end
```

### 2.5. `db/migrate/`
- **マイグレーションファイル**は、データベースのスキーマを管理します。例えば、`create_bookmarks.rb` というファイルでブックマークテーブルを作成します。

### 2.6. `test/`
- **RSpecテスト**  
  - コントローラー、モデル、統合テストなどを行います。正常系テストと異常系テストをカバーし、アプリケーションの動作が正しいかを確認します。

### 2.7. `Gemfile`
- このファイルでは、プロジェクトで使用するgem（ライブラリ）を管理します。Devise（認証）、RSpec（テスト）、その他の便利なライブラリを追加します。

```ruby
gem 'rails', '6.1.4'
gem 'devise'
gem 'rspec-rails'
gem 'pg'  # PostgreSQLのデータベースを使用
```

### 2.8. `README.md`
- プロジェクトの概要、セットアップ方法、使い方などを記載するファイルです。ポートフォリオにおいて、外部の人がプロジェクトを理解しやすいように説明します。

---

## 3. ルーティング

- **ログイン関連**
  - `/login`: ログイン画面
  - `/register`: ユーザー登録画面

- **ブックマーク関連**
  - `/bookmarks`: ブックマークの一覧ページ
  - `/bookmarks/new`: 新しいブックマークを追加するフォーム
  - `/bookmarks/:id`: 特定のブックマークの詳細ページ

- **マイページ関連**
  - `/mypage`: ユーザーのプロフィール管理画面

---

## 4. データベース設計

### `bookmarks` テーブル
| カラム       | 型         | 備考                     |
|--------------|------------|--------------------------|
| id           | bigint     | 自動採番                  |
| title        | text       | ブックマークのタイトル    |
| url          | text       | ブックマークのURL         |
| description  | text       | ブックマークの概要       |
| user_id      | uuid       | `users`テーブルの外部キー |
| tags         | text[]     | タグ（配列として保存）     |
| created_at   | timestamptz| 作成日時                 |
| updated_at   | timestamptz| 更新日時                 |

### `users` テーブル
| カラム        | 型       | 備考                         |
|---------------|----------|------------------------------|
| id            | uuid     | 自動生成                     |
| email         | text     | メールアドレス               |
| password_digest | text   | パスワードのハッシュ         |
| name          | text     | ユーザー名                   |
| created_at    | timestamptz | 作成日時                    |
| updated_at    | timestamptz | 更新日時                    |

---

## 5. 進捗管理とフィードバック

- **毎週進捗確認**: 定期的に進捗を確認し、遅れが生じた場合は計画を調整
- **コードレビュー**: メンターやオンラインコミュニティでフィードバックを受け、改善点を見つける

---

この構成を基に、必要な機能の実装を段階的に進め、最終的にはAI機能や拡張性を加えていくことで、ポートフォリオとして優れたものを作り上げることができます。