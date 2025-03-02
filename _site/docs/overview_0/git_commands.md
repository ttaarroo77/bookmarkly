# Git コマンド履歴

## Bootstrap 導入時の変更

```bash
# 変更内容の確認
git status

# 変更をステージングに追加
git add .gitignore
git add Gemfile
git add app/assets/stylesheets/application.scss
git add app/javascript/application.js
git add config/importmap.rb
git add app/views/layouts/application.html.erb

# 変更内容をコミット
git commit -m "feat: Bootstrap の導入
- Bootstrap gem の追加
- アセットパイプラインの設定
- JavaScript の設定
- レイアウトファイルの更新"
```

## ブックマーク機能の実装

```bash
# 変更内容の確認
git status

# 変更をステージングに追加
git add app/models/bookmark.rb
git add app/models/user.rb
git add app/controllers/bookmarks_controller.rb
git add app/views/bookmarks/

# 変更内容をコミット
git commit -m "feat: ブックマーク機能の実装
- Bookmark モデルの作成と関連付け
- BookmarksController の実装
- ブックマーク関連のビューファイル作成"
```

## コミットメッセージの例

```bash
# 機能のビュー実装時の例
git commit -m "feat: ブックマーク機能のビューを実装
- index ビューでブックマーク一覧を表示
- new/edit フォームの共通パーシャル作成
- show ビューでブックマーク詳細を表示
- Bootstrap を使用したUI/UXの改善"

# 設定変更時の例
git commit -m "config: 開発環境の設定を更新
- データベース設定の調整
- ログレベルの変更
- アセットの設定変更"

# バグ修正時の例
git commit -m "fix: ブックマーク作成時のエラーを修正
- パラメータのバリデーション追加
- エラーメッセージの表示を改善
- リダイレクト処理の修正"
``` 