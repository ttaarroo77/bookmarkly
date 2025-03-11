
## Prompty 機能拡張実装手順とトラブルシューティング

### 全体概要

このドキュメントは、Promptyアプリケーションに以下の機能拡張を実装する手順と、発生した問題のトラブルシューティングについて説明します。

- タグ削除時の確認ダイアログ実装
- 未使用タグの自動削除機能実装
- AIによるタグ候補提案機能実装
- AIによるプロンプト説明文自動生成機能実装

### 目次

1. 開発準備
2. タグ削除時の確認ダイアログ実装
  2.1. 問題と対策 (詳細)
3. 未使用タグの自動削除機能実装
4. AIによるタグ候補提案機能実装
5. AIによるプロンプト説明文自動生成機能実装
6. Procfileの更新とデプロイ準備
7. テストとデバッグ
8. デプロイ


### 1. 開発準備

#### 1.1 ブランチ作成

機能拡張用のブランチを作成します。

git checkout -b feature/ai-enhancements

#### 1.2 必要なGemの追加

Gemfileに必要なライブラリを追加し、bundle installを実行します。

# Gemfile
# バックグラウンド処理用
gem 'sidekiq', '~> 6.5'

# HTTP通信用
gem 'httparty', '~> 0.20'

# HTMLパース用
gem 'nokogiri', '~> 1.13'

# OpenAI API用
gem 'ruby-openai', '~> 3.7'
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Ruby
IGNORE_WHEN_COPYING_END
bundle install
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END
1.3 環境変数の設定

.env.developmentファイルを作成し、以下の環境変数を設定します。.gitignoreに.env.developmentを追加することを忘れないでください。

OPENAI_API_KEY=your_api_key_here
REDIS_URL=redis://localhost:6379/0
AI_API_ENDPOINT=https://api.openai.com/v1/chat/completions
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END
1.4 Redisのセットアップ

Redisをインストールし、起動します。

# macOSの場合
brew install redis
brew services start redis

# Ubuntuの場合
sudo apt-get install redis-server
sudo systemctl start redis-server
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END


### 2. タグ削除時の確認ダイアログ実装

#### 2.1 JavaScriptコントローラーの作成

Stimulusコントローラーを作成し、確認ダイアログのロジックを実装します。

rails g stimulus tag
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END
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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
JavaScript
IGNORE_WHEN_COPYING_END
2.2 タグコントローラーの更新

destroyアクションでタグ削除処理とフラッシュメッセージを設定します。


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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Ruby
IGNORE_WHEN_COPYING_END
2.3 ビューの更新

タグリスト表示部分で、Stimulusコントローラーとdata属性を設定します。

<!-- app/views/prompts/_tag_list.html.erb -->
<div data-controller="tag">
  <% tags.each do |tag| %>
    <span class="tag">
      <%= tag.name %>
      <%= link_to "×", tag_path(tag),
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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Erb
IGNORE_WHEN_COPYING_END


#### 2.1. 問題と対策 (詳細)

問題概要:
問題: タグ削除時に確認ダイアログが表示されない
発生環境: Rails 8.0.1 + Stimulus + Turbo 環境
期待動作: タグ削除リンククリック時に確認ダイアログが表示され、ユーザーが確認できる
現状: クリック時に確認なしで削除処理が実行される
原因分析:
主要原因: Rails 7 以降でデフォルト設定が変更され、rails-ujs が自動読み込みされなくなった

関連問題:
  - Turbo との競合 (Turbo がイベントを横取りしている可能性)
  - Stimulus コントローラーの接続問題
  - JavaScript アセットのロード問題
  - パッケージバージョンの不一致


#### 実施した対策と仮説検証:

#### Stimulusコントローラーの接続確認:

- 仮説: Stimulus コントローラーが正しく接続されていない
- 対策:
  - ビューの data 属性 (data-controller, data-action) が正しく設定されているか確認。
  - Stimulus のデバッグモードを有効化 (application.debug = true) し、コンソールログでコントローラーが読み込まれているか確認。
  - tag_controller.js 内で console.log を使用して、confirmDelete メソッドが呼び出されているか確認。

#### Turboとの競合調査:

- 仮説: Turbo がクリックイベントを横取りし、確認ダイアログが表示される前にリクエストを送信している。
- 対策:
  - 一時的に data: { turbo: false } をリンクに追加し、Turbo を無効化して動作確認。
  - Turbo のイベント (turbo:before-visit) をフックし、data-confirm 属性を持つ要素に対して確認ダイアログを表示する処理を追加 (高度な対策)。

####  Rails UJS の設定確認:

- 仮説: Rails 7/8 では rails-ujs が自動読み込みされなくなったため、data-confirm 属性が機能していない。
- 対策:
  - application.jsで@rails/ujsをimportし、Rails.start()を実行

  - package.jsonを確認し、必要に応じて@rails/ujsのバージョンを更新

#### JavaScript アセットのロード問題:

- 仮説: アセットパイプラインの設定が不適切で、JavaScript ファイルが正しく読み込まれていない。
- 対策:
  - 開発環境の設定 (config/environments/development.rb) で、アセットのデバッグモードとコンパイルを 有効化 (config.assets.debug = true, config.assets.compile = true)。
  - bin/rails assets:clobber と bin/rails assets:precompile RAILS_ENV=development を実行し、アセットを再コンパイル。


#### ブラウザキャッシュの問題:

- 仮説: ブラウザに古いJavaScriptファイルがキャッシュされており、更新が反映されていない
- 対策:
  - ブラウザのハードリロード (Ctrl+Shift+R / Cmd+Shift+R) を実行。
  - 開発者ツールの「キャッシュの消去とハード再読み込み」を実行
  - アセットのバージョニングを行い、強制的にキャッシュをクリア(config.assets.version)

#### 現状と次のステップ:

- 現状: 一時的な対処としてインライン JavaScript による確認ダイアログを実装済み。
- 次のステップ: 上記の仮説検証を詳細に行い、根本的な原因を特定して恒久的な対策を実施する。特に Stimulus コントローラーの接続問題と Turbo との競合解決を優先的に行う。

3. 未使用タグの自動削除機能実装
3.1 タグモデルの更新

コールバック機能と未使用タグ削除のクラスメソッドを追加します。

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Ruby
IGNORE_WHEN_COPYING_END



#### 3.2 プロンプトコントローラーの更新

プロンプト更新後に未使用タグを削除する処理を追加します。

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Ruby
IGNORE_WHEN_COPYING_END


#### 4. AIによるタグ候補提案機能実装

#### 4.1 データベース準備

タグ候補を保存するテーブルを作成します。

rails g model TagSuggestion prompt:references name:string confidence:float applied:boolean
rails db:migrate
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END


#### 4.2 AIサービスクラスの作成

AIによるタグ候補生成のロジックを実装します。

mkdir -p app/services
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END


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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Ruby
IGNORE_WHEN_COPYING_END


#### 4.3 バックグラウンドジョブの作成

Sidekiqの設定ファイルと、タグ候補生成ジョブを作成します。

# config/initializers/sidekiq.rb
redis_url = ENV['REDIS_URL'] || 'redis://localhost:6379/0'

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Ruby
IGNORE_WHEN_COPYING_END


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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Ruby
IGNORE_WHEN_COPYING_END
4.4 コントローラーの更新

プロンプト作成時にジョブを登録する処理を追加します。


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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Ruby
IGNORE_WHEN_COPYING_END
4.5 ビューの更新

タグ候補を表示するUIを実装します。

<!-- app/views/prompts/_tag_suggestions.html.erb -->
<% if prompt.tag_suggestions.where(applied: false).exists? %>
  <div class="tag-suggestions mt-3">
    <h6>タグ候補:</h6>
    <div class="d-flex flex-wrap">
      <% prompt.tag_suggestions.where(applied: false).each do |suggestion| %>
        <%= link_to suggestion.name, apply_tag_suggestion_prompt_path(prompt, suggestion_id: suggestion.id),
            method: :post,
            class: "badge bg-light text-dark me-2 mb-2 p-2" %>
      <% end %>
    </div>
  </div>
<% end %>
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Erb
IGNORE_WHEN_COPYING_END
<!-- app/views/prompts/_prompt.html.erb -->
<div class="card mb-3">
  <!-- 既存のプロンプト表示コード -->

  <!-- タグ候補表示部分を追加 -->
  <%= render 'tag_suggestions', prompt: prompt %>
</div>
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Erb
IGNORE_WHEN_COPYING_END
5. AIによるプロンプト説明文自動生成機能実装
5.1 データベース準備

AI処理の状態を管理するカラムをプロンプトモデルに追加します。

rails g migration AddAiFieldsToPrompts ai_status:string ai_processed_at:datetime ai_error:text
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END
# db/migrate/YYYYMMDDHHMMSS_add_ai_fields_to_prompts.rb
class AddAiFieldsToPrompts < ActiveRecord::Migration[6.1]
  def change
    add_column :prompts, :ai_status, :string, default: 'pending'
    add_column :prompts, :ai_processed_at, :datetime
    add_column :prompts, :ai_error, :text
  end
end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Ruby
IGNORE_WHEN_COPYING_END
rails db:migrate
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END
5.2 AIサービスクラスの拡張

説明文生成機能をAiServiceクラスに追加します。

# app/services/ai_service.rb に追加
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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Ruby
IGNORE_WHEN_COPYING_END
5.3 バックグラウンドジョブの作成

説明文生成ジョブを作成します。

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Ruby
IGNORE_WHEN_COPYING_END
5.4 コントローラーの更新

プロンプト作成時に説明文生成ジョブを登録する処理を追加します。

# app/controllers/prompts_controller.rb
def create
  @prompt = current_user.prompts.build(prompt_params)

  if @prompt.save
    # 説明文生成ジョブをキューに追加
    GeneratePromptSummaryJob.perform_later(@prompt.id)
    # タグ候補生成ジョブをキューに追加(4章のコードと統合)
    GenerateTagSuggestionsJob.perform_later(@prompt.id)

    flash[:success] = "プロンプトを保存しました。AI処理を実行中..."
    redirect_to prompts_path
  else
    render :new
  end
end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Ruby
IGNORE_WHEN_COPYING_END
5.5 ビューの更新

説明文を表示するUIを実装します。

<!-- app/views/prompts/_prompt.html.erb -->
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
        <% if prompt.ai_processed_at.present? %>
          <small class="text-muted">
            AI生成: <%= l prompt.ai_processed_at, format: :short %>
          </small>
        <% end %>
      </div>
    <% elsif prompt.ai_status == 'processing' %>
      <div class="mb-3">
        <div class="d-flex align-items-center text-muted">
          <div class="spinner-border spinner-border-sm me-2"></div>
          AI概要を生成中...
        </div>
      </div>
    <% elsif prompt.ai_status == 'failed' %>
      <div class="mb-3">
        <div class="text-danger">
          <small>AI概要の生成に失敗しました</small>
        </div>
      </div>
    <% end %>

    <!-- タグ表示部分 -->
    <!-- タグ候補表示部分(4章のコードと統合) -->
  </div>
</div>
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Erb
IGNORE_WHEN_COPYING_END
6. Procfileの更新とデプロイ準備
6.1 Procfileの作成

Procfileを作成し、WebプロセスとSidekiqワーカーを定義します。

web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END
6.2 Sidekiq設定ファイルの作成

config/sidekiq.ymlを作成し、Sidekiqの設定を行います。

# config/sidekiq.yml
:concurrency: 5
:queues:
  - default
  - mailers
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Yaml
IGNORE_WHEN_COPYING_END
6.3 デプロイスクリプトの更新

デプロイ時にSidekiqワーカーを再起動するかどうかを確認

# deploy_safe.shに追加
echo "Sidekiqワーカーを再起動しますか？ (y/n)"
read RESTART_WORKER
if [ "$RESTART_WORKER" = "y" ]; then
  heroku ps:restart worker
fi
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END

#### 7. テストとデバッグ

#### 7.1 ユニットテスト作成

- モデル (Tag, TagSuggestion, Prompt) のテスト
- サービスクラス (AiService) のテスト
- ジョブ (GenerateTagSuggestionsJob, GeneratePromptSummaryJob) のテスト

#### 7.2 統合テスト作成

- コントローラー (PromptsController, TagsController) のテスト
- ビューのテスト
- ユーザーフロー全体のテスト (プロンプトの作成、タグ付け、AI機能の利用など)

#### 7.3 エラーハンドリングの強化

- API接続エラー (OpenAI API, HTTParty) への対応
- バックグラウンド処理のエラー (Sidekiq) への対応 (リトライ処理、エラーログなど)

#### 7.4 パフォーマンス最適化

- キャッシュ戦略の実装 (APIレスポンスのキャッシュ、データベースクエリの最適化など)
- バックグラウンド処理の最適化 (ジョブの分割、並列処理など)


#### 8. デプロイ

#### 8.1 環境変数の設定

Herokuの環境変数を設定します。

heroku config:set OPENAI_API_KEY=your_api_key_here
heroku config:set AI_API_ENDPOINT=https://api.openai.com/v1/chat/completions
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END

#### 8.2 Redisアドオンの追加

Heroku Redisアドオンを追加します。

heroku addons:create heroku-redis:mini
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END

#### 8.3 デプロイ実行

コードをコミットし、Herokuにデプロイします。

git add .
git commit -m "AI機能の実装"
git push origin feature/ai-enhancements
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END

#### 8.4 プルリクエストを作成し、mainブランチにマージします。

git checkout main
git pull
git push heroku main
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END

#### 8.5 マイグレーション

heroku run rails db:migrate
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END

以上が、Promptyの機能拡張実装手順とトラブルシューティングの詳細なドキュメントです。 各ステップを丁寧に実行し、問題が発生した場合は詳細なトラブルシューティング手順を参照して解決してください。






<!-- 

# Prompty 機能拡張実装手順

## 1. 開発準備

### 1.1 ブランチ作成
- [ ] 機能拡張用のブランチを作成
  ```bash
  git checkout -b feature/ai-enhancements
  ```

### 1.2 必要なGemの追加
- [ ] Gemfileに必要なライブラリを追加
  ```ruby
  # Gemfile
  # バックグラウンド処理用
  gem 'sidekiq', '~> 6.5'
  
  # HTTP通信用
  gem 'httparty', '~> 0.20'
  
  # HTMLパース用
  gem 'nokogiri', '~> 1.13'
  
  # OpenAI API用
  gem 'ruby-openai', '~> 3.7'
  ```
- [ ] bundle installの実行
  ```bash
  bundle install
  ```

### 1.3 環境変数の設定
- [ ] .env.development ファイルの作成
  ```
  OPENAI_API_KEY=your_api_key_here
  REDIS_URL=redis://localhost:6379/0
  AI_API_ENDPOINT=https://api.openai.com/v1/chat/completions
  ```
- [ ] .gitignoreに.env.developmentを追加

### 1.4 Redisのセットアップ
- [ ] Redisのインストールと起動
  ```bash
  # macOSの場合
  brew install redis
  brew services start redis
  
  # Ubuntuの場合
  sudo apt-get install redis-server
  sudo systemctl start redis-server
  ```

## 2. タグ削除時の確認ダイアログ実装

### 2.1 JavaScriptコントローラーの作成
- [ ] Stimulusコントローラーの作成
  ```bash
  rails g stimulus tag
  ```
- [ ] コントローラーの実装
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

### 2.2 タグコントローラーの更新
- [ ] destroyアクションの実装
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

### 2.3 ビューの更新
- [ ] タグリスト表示部分の修正
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

## 3. 未使用タグの自動削除機能実装

### 3.1 タグモデルの更新
- [ ] コールバック機能の追加
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

### 3.2 プロンプトコントローラーの更新
- [ ] タグ更新後の未使用タグ削除処理追加
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

## 4. AIによるタグ候補提案機能実装

### 4.1 データベース準備
- [ ] タグ候補テーブルの作成
  ```bash
  rails g model TagSuggestion prompt:references name:string confidence:float applied:boolean
  ```
- [ ] マイグレーションファイルの実行
  ```bash
  rails db:migrate
  ```

### 4.2 AIサービスクラスの作成
- [ ] サービスディレクトリの作成
  ```bash
  mkdir -p app/services
  ```
- [ ] AIサービスクラスの実装
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

### 4.3 バックグラウンドジョブの作成
- [ ] Sidekiq設定ファイルの作成
  ```ruby
  # config/initializers/sidekiq.rb
  redis_url = ENV['REDIS_URL'] || 'redis://localhost:6379/0'

  Sidekiq.configure_server do |config|
    config.redis = { url: redis_url }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: redis_url }
  end
  ```
- [ ] タグ候補生成ジョブの実装
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

### 4.4 コントローラーの更新
- [ ] プロンプト作成時のジョブ登録処理追加
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

### 4.5 ビューの更新
- [ ] タグ候補表示UI実装
  ```erb
  <!-- app/views/prompts/_tag_suggestions.html.erb -->
  <% if prompt.tag_suggestions.where(applied: false).exists? %>
    <div class="tag-suggestions mt-3">
      <h6>タグ候補:</h6>
      <div class="d-flex flex-wrap">
        <% prompt.tag_suggestions.where(applied: false).each do |suggestion| %>
          <%= link_to suggestion.name, apply_tag_suggestion_prompt_path(prompt, suggestion_id: suggestion.id), 
              method: :post, 
              class: "badge bg-light text-dark me-2 mb-2 p-2" %>
        <% end %>
      </div>
    </div>
  <% end %>
  ```
- [ ] プロンプト表示部分に追加
  ```erb
  <!-- app/views/prompts/_prompt.html.erb -->
  <div class="card mb-3">
    <!-- 既存のプロンプト表示コード -->
    
    <!-- タグ候補表示部分を追加 -->
    <%= render 'tag_suggestions', prompt: prompt %>
  </div>
  ```

## 5. AIによるプロンプト説明文自動生成機能実装

### 5.1 データベース準備
- [ ] プロンプトモデルの更新
  ```bash
  rails g migration AddAiFieldsToPrompts ai_status:string ai_processed_at:datetime ai_error:text
  ```
- [ ] マイグレーションファイルの編集
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
- [ ] マイグレーションの実行
  ```bash
  rails db:migrate
  ```

### 5.2 AIサービスクラスの拡張
- [ ] 説明文生成機能の実装
  ```ruby
  # app/services/ai_service.rb に追加
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

### 5.3 バックグラウンドジョブの作成
- [ ] 説明文生成ジョブの実装
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

### 5.4 コントローラーの更新
- [ ] プロンプト作成時のジョブ登録処理追加
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

### 5.5 ビューの更新
- [ ] 説明文表示UI実装
  ```erb
  <!-- app/views/prompts/_prompt.html.erb -->
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
          <% if prompt.ai_processed_at.present? %>
            <small class="text-muted">
              AI生成: <%= l prompt.ai_processed_at, format: :short %>
            </small>
          <% end %>
        </div>
      <% elsif prompt.ai_status == 'processing' %>
        <div class="mb-3">
          <div class="d-flex align-items-center text-muted">
            <div class="spinner-border spinner-border-sm me-2"></div>
            AI概要を生成中...
          </div>
        </div>
      <% elsif prompt.ai_status == 'failed' %>
        <div class="mb-3">
          <div class="text-danger">
            <small>AI概要の生成に失敗しました</small>
          </div>
        </div>
      <% end %>
      
      <!-- タグ表示部分 -->
      <!-- タグ候補表示部分 -->
    </div>
  </div>
  ```

## 6. Procfileの更新とデプロイ準備

### 6.1 Procfileの作成
- [ ] Procfileの作成
  ```
  web: bundle exec puma -C config/puma.rb
  worker: bundle exec sidekiq -C config/sidekiq.yml
  ```

### 6.2 Sidekiq設定ファイルの作成
- [ ] config/sidekiq.ymlの作成
  ```yaml
  # config/sidekiq.yml
  :concurrency: 5
  :queues:
    - default
    - mailers
  ```

### 6.3 デプロイスクリプトの更新
- [ ] deploy_safe.shの更新
  ```bash
  # deploy_safe.shに追加
  echo "Sidekiqワーカーを再起動しますか？ (y/n)"
  read RESTART_WORKER
  if [ "$RESTART_WORKER" = "y" ]; then
    heroku ps:restart worker
  fi
  ```

## 7. テストとデバッグ

### 7.1 ユニットテスト作成
- [ ] モデルテスト
- [ ] サービスクラステスト
- [ ] ジョブテスト

### 7.2 統合テスト作成
- [ ] コントローラーテスト
- [ ] ビューテスト
- [ ] ユーザーフロー全体テスト

### 7.3 エラーハンドリングの強化
- [ ] API接続エラー対応
- [ ] バックグラウンド処理エラー対応

### 7.4 パフォーマンス最適化
- [ ] キャッシュ戦略の実装
- [ ] バックグラウンド処理の最適化

## 8. デプロイ

### 8.1 環境変数の設定
- [ ] Herokuの環境変数設定
  ```bash
  heroku config:set OPENAI_API_KEY=your_api_key_here
  heroku config:set AI_API_ENDPOINT=https://api.openai.com/v1/chat/completions
  ```

### 8.2 Redisアドオンの追加
- [ ] Heroku Redisアドオンの追加
  ```bash
  heroku addons:create heroku-redis:mini
  ```

### 8.3 デプロイ実行
- [ ] コミットとプッシュ
  ```bash
  git add .
  git commit -m "AI機能の実装"
  git push origin feature/ai-enhancements
  ```
- [ ] プルリクエスト作成とマージ
- [ ] 本番環境へのデプロイ
  ```bash
  git checkout main
  git pull
  git push heroku main
  ```
- [ ] マイグレーション実行
  ```bash
  heroku run rails db:migrate
  ``` 


  ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

  進捗レポート：タグ削除時の確認ダイアログ問題解決
1. 問題概要
問題: タグ削除時に確認ダイアログが表示されない
発生環境: Rails 8.0.1 + Stimulus + Turbo環境
期待動作: タグ削除リンククリック時に確認ダイアログが表示され、ユーザーが確認できる
現状: クリック時に確認なしで削除処理が実行される
2. 原因分析
主要原因: Rails 7以降でデフォルト設定が変更され、rails-ujsが自動読み込みされなくなった
関連問題:
Turboとの競合（Turboがイベントを横取りしている可能性）
Stimulusコントローラーの接続問題
JavaScriptアセットのロード問題
パッケージバージョンの不一致
3. 実施した対策
パッケージ依存関係の修正:
@hotwired/turbo-railsから@hotwired/turboに変更（バージョン8.0.13）
package.jsonの依存関係を更新
アセットパイプラインの設定:
開発環境で静的アセット提供を有効化
アセットのデバッグモードを有効化
レイアウトファイルの修正:
Bootstrapの読み込み方法を修正
インラインJavaScriptによる一時的な対処を実装
importmapの設定:
必要なJavaScriptライブラリのマッピングを修正
Bootstrapの依存関係を追加
application.jsの修正:
必要なライブラリのインポート順序を修正
Turboのデバッグログを追加
4. 現状と次のステップ
現状: 一時的な対処としてインラインJavaScriptによる確認ダイアログを実装
次のステップ:
Stimulusコントローラーの接続問題を解決
tag_controller.jsの動作確認
データ属性の正しい設定を確認
Turboとの競合解決
5. 教訓と推奨事項
Rails 7/8環境ではrails-ujsとturboの関係に注意が必要
Stimulusコントローラーのデバッグモードを有効にすると問題発見が容易になる
アセットパイプラインの設定が重要
パッケージバージョンの互換性確認が必須
6. 参考資料
Rails 8.0.1のドキュメント
Hotwire（Stimulus + Turbo）の公式ガイド
プロジェクト内の実装手順書（docs/progress_report/20240615_implementation_steps.md

＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝


タグ削除時の確認ダイアログ問題解決に関する分析
必要なファイル
app/javascript/controllers/tag_controller.js
Stimulusコントローラーの実装
確認ダイアログの処理を担当
app/views/tags/tag.html.erb または app/views/prompts/_tag_list.html.erb
タグ削除リンクを含むビューファイル
データ属性の設定が重要
app/javascript/controllers/application.js
Stimulusアプリケーションの設定
デバッグモードの有効化が必要
app/javascript/controllers/index.js
コントローラーの登録
正しく読み込まれているか確認
config/importmap.rb
JavaScriptライブラリのマッピング
依存関係の設定
問題の原因に関する仮説と対策
仮説1: Stimulusコントローラーが正しく接続されていない
原因:
データ属性（data-controller、data-action）が正しく設定されていない
コントローラーファイルが正しく読み込まれていない
対策:
ビューファイルの修正:
   <%= link_to "×", tag_path(tag), 
       data: { 
         controller: "tag",
         action: "click->tag#confirmDelete",
         tag_name: tag.name,
         tag_prompt_count: tag.prompts.count
       },
       class: "delete-tag" %>
Stimulusデバッグモードの有効化:
   // app/javascript/controllers/application.js
   import { Application } from "@hotwired/stimulus"
   const application = Application.start()
   application.debug = true // デバッグモードを有効化
   export { application }
仮説2: Turboとの競合
原因:
Turboがクリックイベントを横取りし、確認ダイアログが表示される前にリクエストを送信している
対策:
Turboを無効化:
   <%= link_to "×", tag_path(tag), 
       data: { 
         turbo: false,
         controller: "tag",
         action: "click->tag#confirmDelete",
         tag_name: tag.name,
         tag_prompt_count: tag.prompts.count
       },
       class: "delete-tag" %>
Turboのイベントをフックして処理:
   // app/javascript/application.js
   document.addEventListener("turbo:before-visit", function(event) {
     const element = event.target;
     if (element.hasAttribute("data-confirm")) {
       if (!confirm(element.getAttribute("data-confirm"))) {
         event.preventDefault();
       }
     }
   });
仮説3: Rails UJSの設定不足
原因:
Rails 7/8ではrails-ujsが自動読み込みされなくなった
data-confirm属性が機能していない
対策:
Rails UJSの明示的な読み込み:
   // app/javascript/application.js
   import Rails from "@rails/ujs"
   Rails.start()
package.jsonの確認と更新:
   {
     "dependencies": {
       "@rails/ujs": "^7.1.3"
     }
   }
仮説4: JavaScriptアセットのロード問題
原因:
アセットパイプラインの設定が不適切
JavaScriptファイルが正しく読み込まれていない
対策:
開発環境の設定確認:
   # config/environments/development.rb
   config.assets.debug = true
   config.assets.compile = true
   config.public_file_server.enabled = true
アセットのプリコンパイル:
   bin/rails assets:clobber
   bin/rails assets:precompile RAILS_ENV=development
仮説5: ブラウザキャッシュの問題
原因:
古いJavaScriptファイルがキャッシュされている
更新されたコードが反映されていない
対策:
ブラウザのハードリロード:
Chrome: Ctrl+Shift+R または Cmd+Shift+R
開発者ツールを開いた状態でリロードボタンを右クリックし「キャッシュの消去とハード再読み込み」を選択
アセットのバージョニング:
   # config/environments/development.rb
   config.assets.version = '1.1' # バージョンを変更してキャッシュを無効化
これらの仮説と対策を順番に試すことで、タグ削除時の確認ダイアログ問題を解決できる可能性が高いです。 -->