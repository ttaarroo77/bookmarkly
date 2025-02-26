# タグv2システム開発計画会議議事録

## 日時
2025/02/26

## 参加者
- 開発チーム

## 議題
タグv2システムの開発アプローチとロードマップの検討

## 決定事項

### 1. 開発アプローチ
- 既存タグシステムを維持しながら、新システムを並行開発
- DBファースト + APIテストファーストのアプローチを採用
- curlによるAPIテストを重視し、フロントエンド開発前に動作確認

### 2. 開発フェーズ

#### Phase 1: データベース設計と実装
- [ ] マイグレーションファイルの作成
  ```ruby
  create_table :tag_v2s
  create_table :bookmarks_tag_v2s
  ```
- [ ] モデルの実装（TagV2, アソシエーション）
- [ ] バリデーションの実装
- [ ] 基本的なモデルテストの作成

#### Phase 2: APIエンドポイント実装
- [ ] タグ操作用のAPIエンドポイント追加
- [ ] curlコマンドによるテストケース作成
- [ ] APIレスポンスの検証
- [ ] エラーハンドリングの実装

#### Phase 3: フロントエンド実装
- [ ] タグ入力UIの実装
- [ ] タグ表示UIの実装
- [ ] JavaScriptによるタグ操作の実装
- [ ] エラー表示の実装

#### Phase 4: 移行機能の実装
- [ ] 移行用Rakeタスクの作成
- [ ] 移行テストの実施
- [ ] ロールバック手順の確認

### 3. テスト戦略
1. APIテスト（curl）
```bash
# タグ作成テスト
curl -X POST http://localhost:3000/api/v2/tags \
  -H "Content-Type: application/json" \
  -d '{"tag": {"name": "ruby"}}'

# タグ一覧取得テスト
curl http://localhost:3000/api/v2/tags
```

2. 単体テスト（RSpec）
```ruby
RSpec.describe TagV2, type: :model do
  it "validates name presence"
  it "normalizes name to lowercase"
  it "prevents duplicate tags"
end
```

### 4. マイルストーン
1. DB設計完了: 3/25
2. API実装完了: 3/30
3. FE実装完了: 4/5
4. 移行機能完了: 4/10

## 次回アクション
- [ ] DB設計書の作成
- [ ] APIエンドポイント仕様書の作成
- [ ] curlテストケースの作成

## 備考
- 既存機能は維持しながら、新機能をステップバイステップで実装
- 各フェーズでのテストを重視
- ドキュメント作成を並行して進める

## 関連ドキュメント
- [タグv2仕様書](../specs/tag_v2_spec.md)
- [APIテスト計画](../testing/api_test_plan.md)
- [移行計画書](../migration/tag_migration_plan.md) 




# 学習したこと

- ログの確認：
テストを実行した後、log/test.logファイルを確認することで、Rails.logger.debugで出力されたメッセージを確認できます。これにより、デバッグ情報を取得することができます。

 - ログの使い方：
 適切な箇所に絞ってconsole.log をストックすると、エラーを検知できる

- putsの代わりにRails.logger.debugを使用:
Railsのログにメッセージを出力できます。これにより、テストの実行中にログを確認することができます。

- PIDファイルを削除
rm tmp/pids/server.pid

- プロセスの直接終了
kill -9 54401



ログは log/development.log ファイルに出力されます。以下の方法で確認できます：

- ターミナルでリアルタイムに確認する場合：
tail -f log/development.log

- Railsコンソールで直接確認する場合：
Rails.logger.debug "テストログ"  # これで確認可能

- ターミナルで直接ログを表示する場合：
cat log/development.log

- 最新のログだけを見る場合：
tail -n 100 log/development.log

