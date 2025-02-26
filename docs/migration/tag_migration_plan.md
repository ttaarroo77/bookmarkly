# タグv2システム移行計画書

## 1. 既存システムとの互換性確認

### 現行システム分析
- 現行テーブル構造：
  - tags（id, name, created_at, updated_at）
  - bookmarks_tags（bookmark_id, tag_id）

### 互換性対応
- 新システムでは以下の変更点に注意：
  - テーブル名の変更：`tags` → `tag_v2s`
  - 中間テーブル名の変更：`bookmarks_tags` → `bookmarks_tag_v2s`
  - nameカラムの正規化ロジックの変更

## 2. マイグレーションリスク評価

### 想定されるリスク
1. データ移行時のパフォーマンス影響
   - 対策：バッチ処理での段階的移行
   - 監視：`rails log:tail`でログ監視

2. 一意性制約違反
   - 対策：移行前のデータクリーニング
   ```ruby
   # データクリーニング用Rakeタスク
   namespace :tags do
     desc 'Clean duplicate tags before migration'
     task clean_duplicates: :environment do
       # 重複チェックと正規化
       Tag.all.group_by { |t| t.name.downcase.strip }.each do |_, dupes|
         next if dupes.size == 1
         keep = dupes.first
         dupes[1..-1].each do |dupe|
           dupe.bookmarks.each { |b| b.tags << keep unless keep.bookmarks.include?(b) }
           dupe.destroy
         end
       end
     end
   end
   ```

3. アプリケーション停止時間
   - 対策：メンテナンスウィンドウの設定
   - 想定時間：30分

## 3. ロールバック手順

### 即時ロールバック手順
```bash
# 1. マイグレーションのロールバック
rails db:rollback STEP=1

# 2. モデル変更の取り消し
git checkout HEAD^ app/models/tag_v2.rb

# 3. アプリケーションの再起動
rails restart
```

### 段階的移行時のロールバック
1. 新規タグ作成の停止
2. v2タグの削除
3. 旧システムへの切り戻し

## 4. 移行手順

### 事前準備
1. データバックアップ
```bash
pg_dump -Fc -v -U postgres -d myapp_production > backup_before_tagv2.dump
```

2. テストデータでの移行テスト実施
```bash
RAILS_ENV=test rails tags:migrate_to_v2
```

### 本番移行
1. メンテナンスモード開始
2. データバックアップ確認
3. マイグレーション実行
4. データ整合性チェック
5. アプリケーション再起動
6. 動作確認
7. メンテナンスモード解除

## 5. 移行後の確認項目

- [ ] タグ一覧の表示確認
- [ ] 新規タグ作成の動作確認
- [ ] ブックマークとタグの関連付け確認
- [ ] 検索機能の動作確認
- [ ] パフォーマンスチェック 