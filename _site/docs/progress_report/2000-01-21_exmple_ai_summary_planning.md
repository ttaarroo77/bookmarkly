# ${feature_name} 開発計画書

## 日時
${date}  <!-- 例: 2025/02/26 -->

## 参加者
${participants}  <!-- 例: - 開発チーム -->

## 議題
${agenda}  <!-- 例: ブックマークのAI概要生成機能の開発計画とロードマップの検討 -->

## 決定事項

### 1. 機能概要
${feature_summary}
<!-- 例:
- ブックマーク登録時にAIがURLの内容を解析
- サイトの概要を自動生成して提案
- ユーザーによる概要の編集と保存が可能
-->

### 2. 必要な要素

#### バックエンド
${backend_requirements}
<!-- 例:
- Bookmarkモデルの拡張（descriptionカラム追加）
- OpenAI API連携
- 非同期処理（Active Job + Sidekiq）
- エラーハンドリング
-->

#### フロントエンド
${frontend_requirements}
<!-- 例:
- 概要表示UI
- 編集インターフェース
- ローディング表示
- エラー表示
-->

#### 外部サービス連携
${external_service_requirements}
<!-- 例:
- OpenAI API（GPT-4）の利用
- プロンプト設計
- レート制限対応
-->

### 3. データベース設計
${database_design}
<!-- 例:
```ruby
class AddDescriptionToBookmarks < ActiveRecord::Migration[7.0]
  def change
    add_column :bookmarks, :description, :text
    add_column :bookmarks, :ai_processing_status, :string, default: 'pending'
    add_column :bookmarks, :ai_processed_at, :datetime
  end
end
```
-->

### 4. 開発フェーズ

#### Phase 1: 基盤構築（${phase1_duration}）
${phase1_tasks}
<!-- 例:
- [ ] Bookmarkモデルの拡張
- [ ] OpenAI API連携の基本設定
- [ ] Sidekiq設定
-->

#### Phase 2: 外部サービス連携実装（${phase2_duration}）
${phase2_tasks}
<!-- 例:
- [ ] AI概要生成ジョブの実装
- [ ] プロンプト設計と最適化
- [ ] エラーハンドリング
-->

#### Phase 3: UI実装（${phase3_duration}）
${phase3_tasks}
<!-- 例:
- [ ] ブックマークフォームの拡張
- [ ] 概要表示UI
- [ ] ローディング/エラー表示
-->

#### Phase 4: テストと最適化（${phase4_duration}）
${phase4_tasks}
<!-- 例:
- [ ] 機能テスト
- [ ] パフォーマンス最適化
- [ ] フィードバック対応
-->

### 5. 技術的考慮事項
${technical_considerations}
<!-- 例:
1. API使用コストの管理
2. レート制限への対応
3. API鍵の安全管理
4. ユーザーデータの取り扱い
5. 多数リクエストへの対応
-->

### 6. 必要なGem/ライブラリ
${required_gems}
<!-- 例:
- `ruby-openai`
- `sidekiq`
- `faraday`
- `nokogiri`
-->

## 実装コード例

### サービスクラス
${service_class_example}
<!-- 例:
```ruby
class AiSummaryService
  def self.generate_summary(url)
    # 実装例
  end
end
```
-->

### ジョブクラス
${job_class_example}
<!-- 例:
```ruby
class GenerateBookmarkSummaryJob < ApplicationJob
  # 実装例
end
```
-->

## 次回アクション
${next_actions}
<!-- 例:
- [ ] データベースマイグレーションの作成
- [ ] 外部API連携の基本実装
- [ ] バックグラウンドジョブの設定
- [ ] UI要素の設計
-->

## 備考
${notes}
<!-- 例:
- 段階的な実装を行い、各フェーズでテストを重視
- APIコスト管理の仕組みを検討
- ユーザーフィードバックを収集する仕組みを検討
-->

## 学習したこと
${learnings}
<!-- 例:
- OpenAI APIの使用方法
- Sidekiqによる非同期処理の実装
- APIレート制限への対処方法
-->

## 関連ドキュメント
${related_documents}
<!-- 例:
- [外部API公式ドキュメント](URL)
- [使用ライブラリのドキュメント](URL)
-->

**使い方:**
1. プレースホルダー（${...}）を実際の内容に置き換え
2. コメント内の例を参考に、各セクションを詳細に記述
3. 不要なセクションは削除可能
4. 必要に応じてセクションを追加可能





## デバッグ手順
1. 問題の再現手順を確認
2. エラーメッセージを記録
3. 問題の原因として考えられるものを5～7つ挙げる
4. 1～2つの最も可能性が高い原因に絞り込む
5. 仮説を検証するためのログを追加
6. ログ結果に基づいて修正を実施
7. 修正内容をドキュメント化 


# バグ報告テンプレート

- **バグID**: [自動生成または手動入力]
- **報告日**: [YYYY-MM-DD]
- **報告者**: [名前]
- **バグ概要**: [簡潔な説明]
- **発生条件**: [再現手順]
- **期待する挙動**: [正しい動作]
- **実際の挙動**: [観測された動作]
- **重要度**: [高/中/低]
- **緊急度**: [高/中/低]
- **原因の見立て**: [暫定的な原因分析]
- **対応状況**: [未対応/調査中/修正済み]
- **関連チケット**: [関連するIssue番号など]