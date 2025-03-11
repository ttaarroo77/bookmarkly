# 機能拡張計画書 (2024-06-15)

## 1. 概要

本文書は、Promptyアプリケーションに追加する新機能の詳細と実装手順を記載したものです。主な追加機能は以下の通りです：

1. タグ削除時の確認ダイアログ
2. 未使用タグの自動削除
3. AIによるタグ候補提案
4. AIによるプロンプト説明文自動生成

## 2. 詳細要件

### 2.1 タグ削除時の確認ダイアログ

#### 機能概要
- タグを削除する前に確認ダイアログを表示し、ユーザーの意図を確認する
- 確認ダイアログには、削除対象のタグ名と関連するプロンプト数を表示する

#### 技術要件
- JavaScriptを使用した確認ダイアログの実装
- タグに関連するプロンプト数の取得と表示
- 「キャンセル」と「削除」の選択肢を提供

### 2.2 未使用タグの自動削除

#### 機能概要
- タグが関連付けられているプロンプトがゼロになった場合、そのタグを自動的に削除する
- 削除処理はバックグラウンドで行い、ユーザーに通知する

#### 技術要件
- タグとプロンプトの関連性を監視するコールバック機能
- プロンプト数がゼロになったタグを検出する機能
- 自動削除処理と通知機能

### 2.3 AIによるタグ候補提案

#### 機能概要
- プロンプト登録時に、URLの内容と既存タグを分析し、適切なタグ候補を提案する
- ユーザーは提案されたタグを選択して適用できる

#### 技術要件
- 外部AI APIとの連携（OpenAI APIなど）
- URLの内容取得とテキスト抽出
- 既存タグデータの分析
- バックグラウンドジョブによる非同期処理
- ユーザーインターフェースでのタグ候補表示と選択機能

### 2.4 AIによるプロンプト説明文自動生成

#### 機能概要
- プロンプト登録時に、URLの内容を分析し、適切な説明文を自動生成する
- ユーザーは生成された説明文を編集できる

#### 技術要件
- 外部AI APIとの連携
- URLの内容取得とテキスト抽出
- バックグラウンドジョブによる非同期処理
- 説明文生成状態の管理（pending, processing, completed, failed）
- ユーザーインターフェースでの説明文表示と編集機能

## 3. 開発手順

### 3.1 環境準備
- [ ] 必要なGemのインストール
  - [ ] `sidekiq` - バックグラウンド処理用
  - [ ] `redis` - Sidekiqのバックエンド用
  - [ ] `httparty` - HTTP通信用
  - [ ] `nokogiri` - HTMLパース用
- [ ] Redisサーバーのセットアップ
  - [ ] ローカル環境でのRedisインストール
  - [ ] Sidekiq設定ファイルの作成
- [ ] OpenAI APIキーの取得と設定
  - [ ] APIキーの発行
  - [ ] 環境変数の設定

### 3.2 タグ削除時の確認ダイアログ実装
- [ ] JavaScriptコントローラーの作成
  - [ ] Stimulusコントローラーの作成
  - [ ] 確認ダイアログのロジック実装
- [ ] タグコントローラーの更新
  - [ ] タグに関連するプロンプト数の取得機能追加
  - [ ] 削除処理の実装
- [ ] ビューの更新
  - [ ] タグリスト表示部分の修正
  - [ ] データ属性の追加

### 3.3 未使用タグの自動削除機能実装
- [ ] タグモデルの更新
  - [ ] コールバック機能の追加
  - [ ] 未使用タグ検出メソッドの実装
- [ ] プロンプトコントローラーの更新
  - [ ] タグ更新後の未使用タグ削除処理追加
- [ ] 通知機能の実装
  - [ ] フラッシュメッセージの設定

### 3.4 AIによるタグ候補提案機能実装
- [ ] データベース準備
  - [ ] タグ候補テーブルの作成
  - [ ] マイグレーションファイルの作成と実行
- [ ] AIサービスクラスの作成
  - [ ] OpenAI API連携機能の実装
  - [ ] URLコンテンツ取得機能の実装
  - [ ] タグ抽出ロジックの実装
- [ ] バックグラウンドジョブの作成
  - [ ] タグ候補生成ジョブの実装
  - [ ] Sidekiqワーカーの設定
- [ ] コントローラーの更新
  - [ ] プロンプト作成時のジョブ登録処理追加
- [ ] ビューの更新
  - [ ] タグ候補表示UI実装
  - [ ] タグ選択機能の実装

### 3.5 AIによるプロンプト説明文自動生成機能実装
- [ ] データベース準備
  - [ ] プロンプトモデルの更新
  - [ ] AI処理状態カラムの追加
- [ ] AIサービスクラスの拡張
  - [ ] 説明文生成機能の実装
  - [ ] エラーハンドリングの追加
- [ ] バックグラウンドジョブの作成
  - [ ] 説明文生成ジョブの実装
  - [ ] 状態管理機能の追加
- [ ] コントローラーの更新
  - [ ] プロンプト作成時のジョブ登録処理追加
- [ ] ビューの更新
  - [ ] 説明文表示UI実装
  - [ ] 処理状態表示の実装
  - [ ] 編集機能の実装

### 3.6 テストとデバッグ
- [ ] ユニットテスト作成
  - [ ] モデルテスト
  - [ ] サービスクラステスト
  - [ ] ジョブテスト
- [ ] 統合テスト作成
  - [ ] コントローラーテスト
  - [ ] ビューテスト
  - [ ] ユーザーフロー全体テスト
- [ ] エラーハンドリングの強化
  - [ ] API接続エラー対応
  - [ ] バックグラウンド処理エラー対応
- [ ] パフォーマンス最適化
  - [ ] キャッシュ戦略の実装
  - [ ] バックグラウンド処理の最適化

### 3.7 デプロイ準備
- [ ] 環境変数の設定
  - [ ] OpenAI APIキーの設定
  - [ ] APIエンドポイントの設定
- [ ] Herokuアドオンの追加
  - [ ] Redisアドオンの追加
- [ ] Procfileの更新
  - [ ] Webプロセスの設定
  - [ ] Workerプロセスの設定
- [ ] デプロイスクリプトの更新
  - [ ] マイグレーション実行オプションの追加
  - [ ] ワーカープロセス再起動オプションの追加

## 4. 実装詳細

### 4.1 タグ削除時の確認ダイアログ

```javascript
// app/javascript/controllers/tag_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["deleteButton"]

  confirmDelete(event) {
    const tagName = event.currentTarget.dataset.tagName
    const promptCount = event.currentTarget.dataset.promptCount
    
    if (!confirm(`「${tagName}」タグを削除しますか？\n関連するプロンプト: ${promptCount}件`)) {
      event.preventDefault()
    }
  }
}
```

```ruby
# app/controllers/tags_controller.rb
def destroy
  @tag = current_user.tags.find(params[:id])
  @prompt_count = @tag.prompts.count
  
  if @tag.destroy
    flash[:success] = "タグ「#{@tag.name}」を削除しました"
  else
    flash[:error] = "タグの削除に失敗しました"
  end
  
  redirect_to prompts_path
end
```

```erb
<!-- app/views/prompts/_tag_list.html.erb -->
<div data-controller="tag">
  <% tags.each do |tag| %>
    <span class="tag">
      <%= tag.name %>
      <%= link_to "×", tag_path(tag), 
          method: :delete, 
          data: { 
            controller: "tag",
            action: "click->tag#confirmDelete",
            tag_name: tag.name,
            prompt_count: tag.prompts.count
          },
          class: "delete-tag" %>
    </span>
  <% end %>
</div>
```

### 4.2 未使用タグの自動削除

```ruby
# app/models/tag.rb
class Tag < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :prompts
  
  # タグが使用されているプロンプト数を確認
  def self.cleanup_unused_tags
    Tag.left_joins(:prompts).group(:id).having('COUNT(prompts.id) = 0').destroy_all
  end
  
  # プロンプトとタグの関連付けが削除された後に実行
  after_commit :check_for_cleanup, on: :update
  
  private
  
  def check_for_cleanup
    # タグに関連するプロンプトがなくなった場合、削除
    self.destroy if self.prompts.count == 0
  end
end
```

```ruby
# app/controllers/prompts_controller.rb
def update
  @prompt = current_user.prompts.find(params[:id])
  
  if @prompt.update(prompt_params)
    # タグの更新後、未使用タグを削除
    Tag.cleanup_unused_tags
    flash[:success] = "プロンプトを更新しました"
    redirect_to prompts_path
  else
    render :edit
  end
end
```

### 4.3 AIによるタグ候補提案

```ruby
# app/services/ai_service.rb
class AiService
  def self.generate_tag_suggestions(prompt)
    # URLからコンテンツを取得
    content = fetch_url_content(prompt.url)
    return [] if content.blank?
    
    # 既存のタグを取得
    existing_tags = prompt.user.tags.pluck(:name)
    
    # AI APIにリクエスト
    response = OpenAI::Client.new.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: "あなたはタグ提案AIです。URLの内容に基づいて、適切なタグを5つ提案してください。" },
          { role: "user", content: "以下のコンテンツに適したタグを提案してください。既存のタグ: #{existing_tags.join(', ')}\n\nコンテンツ: #{content}" }
        ]
      }
    )
    
    # レスポンスからタグを抽出
    suggested_tags = parse_tags_from_response(response)
    
    # タグ候補を保存
    suggested_tags.each do |tag_name|
      TagSuggestion.create(
        prompt_id: prompt.id,
        name: tag_name,
        confidence: 0.8, # 仮の信頼度
        applied: false
      )
    end
    
    suggested_tags
  end
  
  private
  
  def self.fetch_url_content(url)
    response = HTTParty.get(url)
    return "" unless response.success?
    
    doc = Nokogiri::HTML(response.body)
    # メタデータとコンテンツを抽出
    title = doc.at_css('title')&.text || ""
    description = doc.at_css('meta[name="description"]')&.[]('content') || ""
    content = doc.css('p').map(&:text).join(" ")[0..1000] # 最初の1000文字を取得
    
    "#{title}\n#{description}\n#{content}"
  end
  
  def self.parse_tags_from_response(response)
    # AIのレスポンスからタグを抽出
    content = response.dig("choices", 0, "message", "content")
    return [] unless content
    
    # 改行で分割し、各行をタグとして扱う
    tags = content.split(/[\n,]/).map(&:strip).reject(&:empty?)
    
    # 先頭の数字や記号を削除
    tags.map { |tag| tag.gsub(/^[\d\.\-\*]+\s*/, '') }
  end
end
```

```ruby
# app/jobs/generate_tag_suggestions_job.rb
class GenerateTagSuggestionsJob < ApplicationJob
  queue_as :default
  
  def perform(prompt_id)
    prompt = Prompt.find_by(id: prompt_id)
    return unless prompt
    
    # AIサービスを使用してタグ候補を生成
    AiService.generate_tag_suggestions(prompt)
  end
end
```

```ruby
# app/controllers/prompts_controller.rb
def create
  @prompt = current_user.prompts.build(prompt_params)
  
  if @prompt.save
    # タグ候補生成ジョブをキューに追加
    GenerateTagSuggestionsJob.perform_later(@prompt.id)
    flash[:success] = "プロンプトを保存しました。タグ候補を生成中..."
    redirect_to prompts_path
  else
    render :new
  end
end
```

### 4.4 AIによるプロンプト説明文自動生成

```ruby
# db/migrate/YYYYMMDDHHMMSS_add_ai_fields_to_prompts.rb
class AddAiFieldsToPrompts < ActiveRecord::Migration[6.1]
  def change
    add_column :prompts, :ai_status, :string, default: 'pending'
    add_column :prompts, :ai_processed_at, :datetime
    add_column :prompts, :ai_error, :text
  end
end
```

```ruby
# app/services/ai_service.rb
def self.generate_prompt_summary(prompt)
  # URLからコンテンツを取得
  content = fetch_url_content(prompt.url)
  return false if content.blank?
  
  begin
    # AI APIにリクエスト
    response = OpenAI::Client.new.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: "あなたはWebページの要約AIです。URLの内容を簡潔に要約してください。" },
          { role: "user", content: "以下のコンテンツを100文字程度で要約してください。\n\n#{content}" }
        ]
      }
    )
    
    # レスポンスから要約を抽出
    summary = response.dig("choices", 0, "message", "content")
    
    if summary.present?
      prompt.update(
        description: summary,
        ai_status: 'completed',
        ai_processed_at: Time.current
      )
      return true
    else
      prompt.update(
        ai_status: 'failed',
        ai_error: 'AIからの応答が空でした'
      )
      return false
    end
  rescue => e
    prompt.update(
      ai_status: 'failed',
      ai_error: e.message
    )
    return false
  end
end
```

```ruby
# app/jobs/generate_prompt_summary_job.rb
class GeneratePromptSummaryJob < ApplicationJob
  queue_as :default
  
  def perform(prompt_id)
    prompt = Prompt.find_by(id: prompt_id)
    return unless prompt
    
    # 処理中に状態を更新
    prompt.update(ai_status: 'processing')
    
    # AIサービスを使用して説明文を生成
    AiService.generate_prompt_summary(prompt)
  end
end
```

```ruby
# app/controllers/prompts_controller.rb
def create
  @prompt = current_user.prompts.build(prompt_params)
  
  if @prompt.save
    # 説明文生成ジョブをキューに追加
    GeneratePromptSummaryJob.perform_later(@prompt.id)
    # タグ候補生成ジョブをキューに追加
    GenerateTagSuggestionsJob.perform_later(@prompt.id)
    
    flash[:success] = "プロンプトを保存しました。AI処理を実行中..."
    redirect_to prompts_path
  else
    render :new
  end
end
```

```erb
<!-- app/views/prompts/_bookmark.html.erb -->
<div class="card mb-3">
  <div class="card-body">
    <h2 class="h5 mb-1"><%= prompt.title %></h2>
    <a href="<%= prompt.url %>" class="text-truncate d-block mb-2 small text-secondary" target="_blank">
      <%= prompt.url %>
      <%= external_link_icon %>
    </a>
    
    <% if prompt.description.present? %>
      <div class="mb-3">
        <p class="mb-2"><%= prompt.description %></p>
        <small class="text-muted">
          AI生成: <%= l prompt.ai_processed_at, format: :short if prompt.ai_processed_at %>
        </small>
      </div>
    <% elsif prompt.processing? %>
      <div class="mb-3">
        <div class="d-flex align-items-center text-muted">
          <div class="spinner-border spinner-border-sm me-2"></div>
          AI概要を生成中...
        </div>
      </div>
    <% elsif prompt.failed? %>
      <div class="mb-3">
        <div class="text-danger">
          <small>AI概要の生成に失敗しました</small>
        </div>
      </div>
    <% end %>
    
    <!-- タグ表示部分 -->
  </div>
</div>
```

## 5. スケジュール

| タスク                         | 期間     | 担当者 |
|------------------------------|----------|-------|
| 環境準備                       | 1日      | 全員   |
| タグ削除時の確認ダイアログ実装     | 1日      | フロントエンド担当 |
| 未使用タグの自動削除機能実装       | 1日      | バックエンド担当 |
| AIによるタグ候補提案機能実装      | 3日      | AI担当 |
| AIによるプロンプト説明文自動生成実装 | 3日      | AI担当 |
| テストとデバッグ                 | 2日      | 全員   |
| デプロイ準備                    | 1日      | インフラ担当 |
| テスト                         | 2日      | 全員   |
| バグ修正                       | 2日      | 全員   |

## 6. 必要なライブラリ・ツール

- **OpenAI API**: AI機能の実装に使用
- **HTTParty**: URLからコンテンツを取得するために使用
- **Nokogiri**: HTMLパースに使用
- **Sidekiq**: バックグラウンドジョブの処理に使用
- **Redis**: Sidekiqのバックエンドとして使用

## 7. 環境変数設定

```
OPENAI_API_KEY=your_api_key_here
REDIS_URL=redis://localhost:6379/0
AI_API_ENDPOINT=https://api.openai.com/v1/chat/completions
```

## 8. デプロイ手順

1. 環境変数の設定
   ```bash
   heroku config:set OPENAI_API_KEY=your_api_key_here
   heroku config:set AI_API_ENDPOINT=https://api.openai.com/v1/chat/completions
   ```

2. Redisアドオンの追加
   ```bash
   heroku addons:create heroku-redis:mini
   ```

3. マイグレーションの実行
   ```bash
   heroku run rails db:migrate
   ```

4. Procfileの更新
   ```
   web: bundle exec puma -C config/puma.rb
   worker: bundle exec sidekiq -C config/sidekiq.yml
   ```

5. アプリケーションのデプロイ
   ```bash
   git push heroku main
   ```

## 9. まとめ

これらの機能拡張により、Promptyアプリケーションはより使いやすく、効率的なプロンプト管理ツールになります。AI機能の追加により、ユーザーの作業負担を軽減し、より質の高いプロンプト管理が可能になります。

実装にあたっては、バックグラウンド処理を活用して、ユーザー体験を損なわないようにすることが重要です。また、AI APIの利用コストを考慮し、適切なキャッシュ戦略を検討する必要があります。



＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

### 人間用のメモ：

タグ削除時の確認ダイアログが表示されない問題の仮説と対策
仮説1: Stimulusコントローラーが正しく接続されていない
原因: data-controller="tag"属性が正しく設定されていないか、Stimulusフレームワークが正しく初期化されていない可能性があります。
対策:
connect()メソッドにコンソールログを追加して、コントローラーが接続されているか確認
ブラウザのコンソールでStimulusのデバッグモードを有効にする（Stimulus.debug = true）
HTMLの構造を確認し、data-controller="tag"が正しい要素に設定されているか確認
仮説2: イベントハンドリングの問題
原因: click->tag#confirmDeleteアクションが正しく設定されていないか、イベントが別のハンドラーによって阻止されている可能性があります。
対策:
onclick属性を追加してネイティブのイベントハンドラーを設定し、クリックイベントが発生しているか確認
イベントオブジェクトの伝播状況を確認するためのログを追加
Turboのイベント処理との競合がないか確認
仮説3: データ属性の問題
原因: data-tag-nameやdata-prompt-count属性が正しく設定されていないか、値が取得できていない可能性があります。
対策:
コンソールログでevent.currentTarget.datasetの内容を確認
データ属性の命名規則を確認（Stimulusではdata-tag-nameはtagNameとして参照される）
属性値が正しく設定されているか確認するためのデバッグコードを追加
仮説4: Turboとの競合
原因: Rails 7のTurboフレームワークがconfirmダイアログの表示前にリクエストを送信している可能性があります。
対策:
data-turbo="false"を追加してTurboを無効化してテスト
data-turbo-confirm属性を使用してTurboのネイティブ確認ダイアログを試す
event.preventDefault()が正しく機能しているか確認するためのログを追加
仮説5: JavaScriptエラーが発生している
原因: 他のJavaScriptエラーによって処理が中断されている可能性があります。
対策:
try-catchブロックでconfirmDelete関数をラップしてエラーをキャッチ
ブラウザのコンソールでエラーが報告されていないか確認
デバッグモードを有効にして詳細なエラー情報を取得
仮説6: ブラウザの設定やポリシーの問題
原因: ブラウザの設定やポリシーによって確認ダイアログの表示がブロックされている可能性があります。
対策:
別のブラウザでテスト
window.confirmの代わりにカスタムモーダルダイアログを実装
ブラウザのポップアップブロック設定を確認
これらの仮説と対策を順番に試すことで、問題の原因を特定し解決できる可能性が高まります。
