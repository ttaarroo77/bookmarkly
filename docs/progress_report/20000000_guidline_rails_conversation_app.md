# [生成AI]共感型カウンセラーボットを作成する - Ruby on Rails7編 ガイドライン

## 概要

本ガイドラインでは、Ruby on Rails 7 を使用して、生成AI（ChatGPT, Claude, Gemini）を活用したLINE風チャットボット（共感型カウンセラーボット）を作成し、Render.com にデプロイして公開するまでの手順を詳細に解説します。

### 主な内容

*   **開発環境構築**: GitHub Codespaces を利用した、迅速かつ容易な開発環境のセットアップ。
*   **チャットUI実装**: LINE風のチャットインターフェースをRailsで構築。
    *   Messagesコントローラー、ビュー、ルーティング、CSSスタイリング。
    *   セッションを利用した会話履歴の管理。
*   **生成AI連携**: 各生成AI (ChatGPT, Claude, Gemini) のAPIキー取得と、Railsアプリケーションとの連携。
    *   `credentials.yml.enc` を使用したAPIキーの安全な管理。
    *   各生成AIに対応したサービスクラス ( `ChatgptService`, `ClaudeService`, `GeminiService` ) の実装。
*   **デプロイ**: Render.com へのデプロイ手順と、デプロイ後の注意点（サービス停止、APIキー無効化）。
*   **免責事項**: 提供コードの利用、生成AIのAPI利用料金、セキュリティに関する注意喚起。

### 対象読者

*   Ruby on Rails の基本的な知識がある方
*   生成AIに興味があり、チャットボット開発に挑戦したい方
*   Webアプリケーションを開発・公開する流れを学びたい方

### ゴール

読者が本ガイドラインを通じて、生成AIを活用したチャットボットを自力で開発・公開できるようになること。

## 詳細

### 第1部　Rails開発環境の構築

*   **GitHub Codespacesの利用**
    *   クラウドIDEによる環境構築の簡略化。
    *   ローカル開発環境との比較 (Ruby 3.2.3, Rails 7.1.3.2)。
*   **GitHubアカウントの作成**
    *   GitHubサインアップページへのアクセスとアカウント作成手順。
    *   メールアドレス確認の重要性。
*   **GitHub Codespacesでの開発開始**
    *   無料プランの利用 (60時間/月)。
    *   **テンプレートからの新規リポジトリ作成**
        *   テンプレートリポジトリの利用方法と利点（初期構成の自動化）。
        *   新規リポジトリ作成手順 (リポジトリ名: `rails-counselor-bot`, Private設定)。
        *   Codespacesの起動 (`Code` ボタン -> `Codespaces` タブ -> `Create codespace on main`)。
    *   **Codespacesでの開発**
        *   `bundle install` によるgemのインストール。
        *   `rails s` によるサーバー起動と動作確認 (Welcome画面表示)。
        *   サーバー停止 (`Ctrl + C`)。

### 第2部　LINE風チャットボット画面を作成する

*   **チャット画面の設計**
    *   LINE風UIの採用理由（親しみやすさ、直感的な操作性）。
    *   メッセージ表示（ユーザー: 右寄せ、ボット: 左寄せ）。
*   **Messagesコントローラーの作成**
    *   `rails generate controller Messages index` コマンドによるコントローラー、ビュー、ルーティングの自動生成。
    *   **`app/controllers/messages_controller.rb` の実装**
        *   `create` アクション:
            *   `params[:message]` によるメッセージ受信。
            *   `session[:messages]` による会話履歴の管理 (配列への追加、セッションへの保存)。
            *   エコーボットの実装 (`assistant_response = params[:message]`)。
            *   `redirect_to messages_path` によるリダイレクト。
        *   `index` アクション:
            *   `@messages = session[:messages] || []` によるメッセージ取得とビューへの受け渡し。
        *   `clear_session` アクション:
            *   `session.delete(:messages)` によるセッション削除。
            *   `redirect_to root_path` によるリダイレクト。
        *   セッションの解説：役割、Railsでの管理方法、チャットアプリでの利用。
*   **ルーティングの設定 (`config/routes.rb`)**
    *   `root 'messages#index'`
    *   `get 'messages', to: 'messages#index'`
    *   `post 'messages', to: 'messages#create'`
    *   `post 'messages/clear', to: 'messages#clear_session', as: 'messages_clear_session'`
    *   `get 'clear_session', to: 'messages#clear_session'`
*   **ビューの作成 (`app/views/messages/index.html.erb`)**
    *   チャットボットコンテナ (`<div id="chat-bot-container">`)。
    *   メッセージ表示部分 (`<div id="messages">`)
        *   `@messages.each` によるメッセージループ。
        *   `message['role']` に基づくクラス付与 (`user` or 空)。
    *   入力部分 (`<div id="message-form">`)
        *   `form_with` ヘルパーの使用。
            *   `url: messages_path`
            *   `local: true`
            *   `id: 'chat-message-form'`
        *   `form.text_field :message`
        *   `form.submit '送信'`
        *   `form.submit '削除', formaction: messages_clear_session_path`
        *    CSRF対策: `form_with(local: true)`とRailsの自動CSRFトークン生成
    *   ページ内スクリプト (`<script>`)
        *   自動スクロール (`document.getElementById('messages').scrollTop = document.getElementById('messages').scrollHeight`)。
        *   セッション内容のコンソール出力 (デバッグ用)。
*   **CSSスタイリング (`app/assets/stylesheets/application.css`)**
    *   `#chat-bot-container`
        *   `width`, `max-width`, `height`, `margin`, `background-color`, `border-radius`, `box-shadow`, `display: flex`, `flex-direction: column`
    *   `#messages`
        *   `flex: 1`, `overflow-y: auto`, `padding`
    *   `.message`
        *   `max-width`, `width: fit-content`, `margin-bottom`, `padding`, `border-radius`, `background-color`
    *   `.message.user`
        *   `margin-left: auto`, `background-color`
    *   `.message p`
    *   `#message-form`
    *   `#chat-message-form`
    *   `#message_input`
    *   `input[type="submit"]`
    *   `input[type="submit"][formaction="/messages/clear"]`
*   **デバッグ**
    *   `rails s` によるサーバー起動。
    *   メッセージ送信とエコー応答の確認。
    *   削除ボタンの動作確認。
*   **コミットとプッシュ**
    *   Gitによる変更のステージング、コミット、プッシュ (コミットメッセージ: "LINE風のチャット画面の作成")。

### 第3部　生成AI連携

*   **生成AIの役割とAPI連携**
    *   インテリジェントな応答生成。
    *   API (Application Programming Interface) の解説。
*   **各生成AIのAPIキー作成**
    *   **OpenAI APIキー**
        *   OpenAIウェブサイトでのアカウント作成/ログイン。
        *   APIキー生成 (`Create new secret key`) と保存。
    *   **Anthropic APIキー**
        *   Anthropicウェブサイトでのアカウント作成/ログイン。
        *   APIキー生成 (`Generate API Key`) と保存。
    *   **Google AI APIキー**
        *   Google Cloud Platformウェブサイトでのアカウント作成/ログイン。
        *   Google AI StudioウェブサイトでのAPIキー生成 (`Create API Key in new project` or `Generative Language Client`) と保存。
        *   2回目以降は、既存プロジェクト(`Generative Language Client`)を選択
*   **APIキーの保護 (credentials.yml.enc)**
    *   秘匿情報の直接組み込みのリスク。
    *   `credentials.yml.enc` の利用 (AES-128-GCM暗号化)。
        *   `config/credentials.yml.enc` のパス。
        *   古い`config/credentials.yml.enc`ファイルの削除（master.key喪失の可能性のため）
        *   `EDITOR=vim rails credentials:edit` コマンドによる編集 (Vimエディタ使用)。
            *   Vimの基本的な使い方: `i` (挿入モード), `Esc` (ノーマルモード), `:wq` (保存して終了), `:q!` (保存せずに終了)。
        *   APIキーの保存形式 (YAML形式)。
        *   `Rails.application.credentials.openai[:api_key]` によるアクセス。
    *   `config/master.key` の取り扱い (.gitignoreへの追加、本番環境での管理)。
        *  master.keyの文字列（32文字のランダム英数字）をメモしておく（第4部Renderのビルド設定で使用）
*   **生成AI用gemのインストール**
    *   `Gemfile` への追記:
        *   `gem 'ruby-openai'`
        *   `gem 'anthropic'`
        *   `gem 'ruby-gemini-ai'`
    *   `bundle install` の実行。
*   **各生成AIのサービスクラス実装**
    *   **`app/services/chatgpt_service.rb` (ChatGPT連携)**
        *   `require 'openai'`
        *   `ChatgptService` クラス:
            *   `self.generate_response(messages)` メソッド:
                *   `OpenAI::Client.new` によるクライアント初期化 (APIキー使用)。
                *   システムプロンプトの設定 (ヒアドキュメント使用)。
                    *   カウンセラーとしての役割、会話のルール、文字数制限などを指示
                *   `client.chat` によるAPI呼び出し (`model: 'gpt-3.5-turbo'`, `messages: system_prompt + messages`)。
                *   レスポンス処理 (エラーチェック、`response.dig('choices', 0, 'message', 'content')` による回答抽出)。
    *   **`app/services/claude_service.rb` (Claude連携)**
        *   `require 'anthropic'`
        *   `ClaudeService` クラス:
            *   `initialize` メソッド:
               *    `@client = Anthropic::Client.new`によるクライアント初期化
            *   `self.generate_response(messages)` メソッド:
                *   システムプロンプトの設定(chatgpt_service.rbと同じ内容)。
                *   `@client.messages` によるAPI呼び出し (`model: "claude-3-opus-20240229"`, `system: system_content`, `messages: messages`, `max_tokens: 1000`)。
                *   レスポンス処理 (エラーチェック、`response.dig('content', 0, 'text')` による回答抽出)。
    *   **`app/services/gemini_service.rb` (Gemini連携)**
        *   `require 'gemini-ai'`
        *   `GeminiService` クラス:
            *   `self.generate_response(messages)` メソッド:
                *   `GeminiAi::Client.new` によるクライアント初期化 (APIキー使用)。
                *   システムプロンプトの設定(chatgpt_service.rbと同じ内容)。
                *   Gemini API仕様に合わせた `contents` 作成:
                    *   `each_with_index` によるメッセージループ。
                    *   最初のメッセージにシステムプロンプトを結合。
                    *   `role` 設定 (`'model'` or `'user'`)。
                    *   `{ 'role' => role, 'parts' => { 'text' => parts_text } }` 形式のハッシュ作成。
                *   `client.generate_content` によるAPI呼び出し (`contents`, `model: "gemini-pro"`)。
                *   レスポンス処理 (エラーチェック、`response.dig('candidates', 0, 'content', 'parts', 0, 'text')` による回答抽出)。
*   **`MessagesController` の修正**
    *   `create` アクション内の `assistant_response` の変更:
        *   コメントアウト: `# assistant_response = params[:message]` (エコーボット), `# assistant_response = ChatgptService.generate_response(messages)`(ChatGPT), `# assistant_response = ClaudeService.generate_response(messages)`(Claude)
        *   利用したい生成AIの呼び出しに変更: `assistant_response = GeminiService.generate_response(messages)`
*   **デバッグ**
    *   `rails s` によるサーバー再起動。
    *   各生成AIとの対話確認。
*   **コミットとプッシュ**
    *   Gitによる変更のステージング、コミット、プッシュ (コミットメッセージ: "生成AI連携を実装")。

### 第4部　Renderにデプロイ

*   **Renderの概要**
    *   クラウドプラットフォーム (スケーラビリティ, HTTPS対応, CI/CD, 無料プラン)。
*   **Renderアカウントの作成**
    *   Render公式サイトでのアカウント作成 (GitHubアカウント連携推奨)。
*   **Renderへのデプロイ手順**
    *   Renderダッシュボードでの操作:
        *   `New +` ボタン -> `Web Service` 選択。
        *   `Build and deploy from a Git repository` 選択。
        *   レポジトリ検索と接続。
        *   ビルド設定:
            *   `Runtime`: `Ruby`
            *   `Build Command`, `Start Command`: 初期値のまま
            *   `Instance Type`: `Free`
            *   `Environment Variables`: `RAILS_MASTER_KEY` (第3部でメモしたmaster.keyの文字列を入力)
        *   `Create Web Service` クリック。
    *   ビルド完了まで待機 (`Your service is live` 表示)。
    *   公開URLクリックによる動作確認。
*   **デバッグ**
*   **サービス停止/削除**
     *   `Settings` -> `Suspend Web Service` or `Delete Web Service`
*  **APIキーの無効化（重要）**
     *  OpenAI、Anthropic、Google AI Studioのサイトにログインして、APIキーを無効化（キーを再生成するか、削除）
## まとめ

本ガイドラインでは、Railsと生成AIを組み合わせたチャットボット開発の全工程を詳細に解説しました。 以下のスキルを習得し、実践的なWebアプリケーション開発の基礎を築くことができたはずです。

*   **GitHub Codespacesによる効率的な開発環境構築**
*   **Railsの基本 (コントローラー、ルーティング、ビュー)**
*   **生成AI APIとの連携 (OpenAI, Anthropic, Google AI)**
*   **Render.comを利用したWebアプリケーションのデプロイと公開**

この知識を応用することで、さらに高度なチャットボットや、他のAIサービスを組み込んだWebアプリケーション開発にも挑戦できるでしょう。


==========

#### 原文：  AI は以下を無視すること：

- URL:
https://note.com/creativival/n/n504dc24f79d6?after_purchase=true


- text:
キーワードやクリエイターで検索

今回は、Ruby on Rails 7を使ってLINE風のチャットボットを作成する方法を紹介します。このチャットボットは、生成AIを利用することで、まるで本物のカウンセラーとチャットしているかのような自然な会話体験を提供します。開発したチャットボットは一般公開して、多くのユーザーに使ってもらえるようにします。

生成AIは、大規模な言語モデルを使用して人間のような応答を生成するためのインターフェースです。このAPIを利用することで、ユーザーの入力に対して適切な返答を生成し、カウンセリングのような対話を実現することができます。チャットボットがユーザーの悩みに共感し、適切なアドバイスを提供することで、ユーザーは自分の気持ちを打ち明けやすくなり、ストレス解消やメンタルヘルスの改善に役立つでしょう。

本記事では、生成AIとして、ChatGPT、Claude、Geminiの3つを選びました。これらは、現在最も高性能な生成AIモデルとして知られており、自然な会話の生成に優れています。各モデルの特徴と利用方法について詳しく解説し、Ruby on Railsでの実装手順を丁寧に説明します。

記事概要
本記事では、Rails7を使ってチャットボットのWebアプリケーションを開発する手順を4部構成で詳しく解説します。

第1部では、Railsの開発環境構築から始まります。開発環境の構築を簡単にできる「GitHub Codespaces」を利用する方法を詳しく解説します。

第2部では、LINE風のチャット画面の実装に進みます。Messagesコントローラーを作成し、ルーティングの設定、ビューファイルの作成、CSSでのスタイリングを行います。最後にデバッグを行い、チャット画面が正常に動作することを確認します。

第3部では、生成AIとの連携方法を説明します。まず、生成AIの APIキーを取得します。次に、Ruby用の生成AI用のgemを導入し、MessagesControllerを修正して、ユーザーのメッセージに対して生成AIが応答を返すようにします。ここまでの作業で、カウンセラーボットは完成します。

最後の第4部では、完成したWebアプリケーションをRender.comにデプロイする方法を紹介します。Renderアカウントの作成方法と、GitHubからRailsプロジェクトをデプロイする手順を説明します。デプロイ後、デバッグを行い、アプリケーションがインターネット上で正常に動作することを確認します。

本記事を通して、読者はRails7と生成AIを使ったチャットボットの開発方法を体系的に学ぶことができます。各部で丁寧に手順を説明しているため、初心者の方でも理解しやすい内容となっています。実際にコードを書きながら進めていくことで、より深い理解が得られるでしょう。

- 目次
記事概要
免責事項
第1部　Rails開発環境の構築
GitHub Codespaces
GitHubアカウントの作成
GitHub Codespacesで開発を始める
テンプレートから新しいレポジトリを作成
Codespacesで開発を開始する
第2部　LINE風チャットボット画面を作成する
チャット画面：Messagesコントローラーの作成
チャット画面：routes.rb
チャット画面：index.html.erb
チャット画面：application.css
チャット画面：デバッグ
チャット画面：コミット
チャット画面：プッシュ
第3部　生成AI連携
OpenAI APIキーの作成
Anthropic APIキーの作成
Google AI APIキーの作成
APIキーを秘匿情報として保護する方法
credentials.yml.encにAPIキーを保存
ChatGPT連携：3つの生成AIのgemをまとめてインストール
ChatGPT連携：ChatgptServiceクラス
ChatGPT連携：MessagesControllerクラスの編集
ChatGPT連携：デバッグ
Claude連携：ClaudeServiceクラス
Claude連携：MessagesControllerクラスの修正
Gemini連携：GeminiServiceクラス
Gemini連携：MessagesControllerクラスの修正
第4部　Renderにデプロイ
Renderとは
Renderアカウントの作成
Renderにデプロイ
サービスの停止・削除
おわりに
第1部　Rails開発環境の構築
本記事では、Ruby on Rails 7を使ってチャットボットを開発します。Rails 7は、Rubyのウェブアプリケーションフレームワークである Ruby on Rails の最新バージョンです。Rails 7には、多くの新機能と改良が含まれており、開発者の生産性を向上させることができます。

まず始めに、開発環境の構築について説明します。Rails開発環境の構築は、時として複雑で時間がかかる作業となることがありますが、本記事ではGitHub Codespacesを使用することで、その過程を大幅に簡略化します。

本記事では、クラウドIDE（Codespaces）を使用しましたが、もちろん他の開発環境でもRails開発を行えます。ローカルで開発するときは、Ruby 3.2.3、　Rails 7.1.3.2でプロジェクトを作成すると、本記事と同じ条件で開発を実行できます。Codespaces以外の開発環境の場合は、環境構築後に第2部まで進んでください。

GitHub Codespaces
GitHub Codespacesは、クラウドベースの統合開発環境（IDE）であり、GitHub上でソースコードを編集、ビルド、デバッグすることができます。Codespacesを使用すれば、ローカルマシンに開発環境を設定する必要がなくなり、どのデバイスからでもプロジェクトにアクセスできるようになります。また、Codespacesには必要な開発ツールやライブラリが予めインストールされているため、すぐに開発を始められます。

それでは、GitHub Codespacesを使った開発環境の構築手順を見ていきましょう。次のセクションに進んでGitHubアカウントの作成を行ってください。

GitHubアカウントの作成
GitHubは、Gitリポジトリをホストするウェブベースのプラットフォームであり、コードの共有、バージョン管理、コラボレーションを容易にする様々な機能を提供します。Codespaces を使用するには、GitHub アカウントが必要となるため、以下の手順に従って作成してください。

以下のリンクにアクセスし、GitHubのサインアップページを開きます。 https://github.com/join

ユーザー名、メールアドレス、パスワードを入力し、「Create account」ボタンをクリックします。

メールアドレスの確認を行います。登録したメールアドレスに送信された確認メールのリンクをクリックし、メールアドレスの確認を完了させてください。

以上で、GitHubアカウントの作成が完了しました。次のセクションでは、GitHub上に新しいリポジトリを作成し、Codespacesを使って開発環境を構築します。

GitHub Codespacesで開発を始める
GitHub Codespaces は、クラウド上の開発環境を提供するサービスです。無料のプランでも「60時間/月」まで使用できます。Codespaces を使うことで、以下のようなことが可能になります。

ブラウザ上で完全な開発環境を利用できる

環境のセットアップや依存関係の管理が自動化され、すぐに開発を始められる

どのマシンからでもプロジェクトにアクセスでき、一貫した開発体験が得られる

Git リポジトリと統合されており、シームレスなバージョン管理が可能

Codespaces は、Visual Studio Code をベースにしたウェブエディタを使用しており、ローカルの Visual Studio Code と同様の使い勝手を提供します。また、Codespaces は、プロジェクトごとにカスタマイズ可能な環境を提供するため、プロジェクトに合わせた最適な開発環境を構築できます。

本記事では、GitHub Codespaces を使用して Rails アプリケーションの開発を行います。ここでは、Codespacesを設定済みのテンプレートレポジトリから新しいリポジトリを作成する方法を説明します。

テンプレートから新しいレポジトリを作成
GitHub上で新しいプロジェクトを始める際、一から全てを設定するのは手間がかかります。そこで、GitHubではテンプレートを使用して新しいリポジトリを作成することができます。テンプレートを使用すると、予め設定された構成やファイルを持つリポジトリを簡単に作成できます。

ここでいうテンプレートとは、リポジトリの構造や設定をあらかじめ定義したものです。テンプレートには、プロジェクトの初期構成、ディレクトリ構造、デフォルトのファイル、Issueテンプレートなどが含まれます。テンプレートを使用することで、プロジェクトの初期設定に費やす時間を大幅に削減できます。

一方、リポジトリは、Gitで管理されるプロジェクトの保存場所です。GitHubでは、リポジトリでソースコードやドキュメントを保存し、バージョン管理を行います。また、リポジトリはコラボレーションの中心となる場所でもあり、他の開発者と一緒にプロジェクトを進めることができます。

本記事では、RailsアプリケーションのためのGitHubテンプレートを用意しています。以下の手順に従って、このテンプレートから新しいリポジトリを作成してください。

以下のリンクにアクセスし、Railsアプリケーションのテンプレートページを開きます。 


画像
図1 テンプレートレポジトリ
テンプレートレポジトリから新しいレポジトリを作成します。右上の「Use this template > Create a new repository」を選びます。

画像
図2 新しいレポジトリを作成
「Create a new repository」ページが開きます。レポジトリ名は任意ですが、ここでは「rails-counselor-bot」としました。このレポジトリでは、APIキーのような秘匿情報を扱うため、情報漏洩のリスクを最小限に抑えることが重要です。そのため、「Private」に設定することをお勧めします。この設定により、許可したアカウントのみがレポジトリにアクセスできるようになります。設定が完了したら、「Create repository」ボタンをクリックして新しいレポジトリを作成します。

画像
図3 Codespaceを作成
新しいレポジトリが開いたら、Codespaceを作成します。「Code」ボタンから「Codespaces」タブの「Create codespace on main」ボタンをクリックします。Codespaceが作成され、クラウドIDEで開発できるようになります。

Codespacesで開発を開始する
画像
図4 Codespacesが開いた
Codespaceが開いたら、アプリケーションに必要なgemをインストールします。ターミナルに、次のコマンドを入力して実行します。

$ bundle install

copy
gemのインストールが終わったら、次のコマンドでサーバーが実行できるか確認します。

$ rails s

copy
画像
図5 rails sコマンド
Railsサーバーが起動し、Railsアプリケーションが使用できるようになりました。「ブラウザで開く」ボタンが表示されるので、クリックしてください。

画像
図6 Rails Welcome画面
Welcome画面が表示できたら、環境構築は完了です。クラウドIDEで開発を始めらるようになりました。「Ctrl + C」キーを押すと、サーバーを閉じることができます。

次のセクションから、LINE風のチャット画面を実装していきます。

第2部　LINE風チャットボット画面を作成する
本記事の第2部では、LINE風のチャットボット画面を作成します。LINEは、日本で最も人気のあるメッセージングアプリの一つであり、多くのユーザーに親しまれています。LINEの簡単で直感的なインターフェースは、ユーザーにとって使いやすく、コミュニケーションを円滑にします。

このチャットボット画面では、ユーザーがメッセージを入力し、送信すると、ユーザーメッセージが右寄せで表示されます。そして、チャットボットからの返信メッセージが左寄せで表示されます。ユーザーは、まるでLINEで友達とチャットをしているかのような感覚で、チャットボットとコミュニケーションを取ることができます。

それでは、次のセクションから、LINE風チャットボット画面の作成に必要なステップを順に見ていきましょう。最初に、チャットボット画面のためのコンローラーを作成します。

チャット画面：Messagesコントローラーの作成
Railsでは、コマンドでコントローラーを作成できます。コントローラーは、ユーザーからのリクエストを受け取り、必要なデータを取得し、ビューに渡して表示する役割を持ちます。コマンドからコントローラーを作成すると、対応するビューとルーティングも同時に設定されます。

ビューは、ユーザーに表示されるHTML、CSS、JavaScriptなどのファイルを管理します。コントローラーから渡されたデータを使って、動的なコンテンツを生成し、ユーザーに表示します。

ルーティングは、ユーザーからのリクエストを適切なコントローラーとアクションに割り当てる役割を持ちます。ルーティングの設定により、URLとコントローラーのアクションが紐付けられ、ユーザーがアクセスしたURLに応じて適切な処理が行われます。

これらの3つの要素は、Railsアプリケーションの中核をなし、相互に協力して機能します。

Codespacesのターミナルで次のコマンドを実行して、コントローラー、ビュー、ルーティングを一括で作成しましょう。

$ rails generate controller Messages index

copy
このコマンドにより、MessagesControllerが作成され、indexアクションに対応するビューとルーティングが自動的に設定されます。次に、Codespacesのプロジェクトマネージャーから「app/controllers/messages_controller.rb」を開きます。そして、次に示すコードに書き換えてください。

class MessagesController < ApplicationController
  def create # （1）
    unless params[:message].empty?
      messages = session[:messages] || []

      # ユーザーのメッセージを表示する
      messages << { 'content' => params[:message], 'role' => 'user' }

      # エコーチャットボット
      assistant_response = params[:message]

      messages << { 'content' => assistant_response, 'role' => 'assistant' }
      session[:messages] = messages
    end

    # p '@messages: ' + messages.to_s
    # p 'session[:messages]' + session[:messages].to_s
    redirect_to messages_path  # create アクション後に index へリダイレクト
  end

  def index # （2）
    @messages = session[:messages] || []
    # p '@messages: ' + @messages.to_s
  end

  def clear_session # （3）
    session.delete(:messages)
    redirect_to root_path
  end
end

copy
MessagesControllerは、ユーザーとボットのメッセージを管理し、ブラウザ画面にメッセージを表示する役割を果たします。ここで実装するのは、エコーボット（ユーザーメッセージと同じメッセージを返す）です。カウンセラーの応答は、次の第3部で実装します。コメント番号部分を解説します。

（1）のcreateアクションは、ユーザーからの入力（メッセージ）を受け取り、それに対する応答を生成し、その両方をセッションに保存する役割を担います。これにより、一時的にユーザーとチャットボットの会話履歴を保持することができます。この処理の主なステップは以下の通りです：

メッセージの受信: フォームから送信されたメッセージがparams[:message]で取得されます。このメッセージが空でない場合のみ処理が進行します。

セッションの利用: session[:messages]を使用して、会話履歴を一時的に保存します。これにより、ページが再読み込みされたり、ユーザーが別のページに移動したりしても、会話の文脈が失われることがありません。session[:messages]が未定義の場合は空の配列[]で初期化されます。

メッセージの保存: ユーザーからのメッセージと、それに対するチャットボットの応答（この例ではエコー）がmessages配列に追加され、その後session[:messages]に再び保存されます。

リダイレクト: 処理が完了した後、ユーザーはmessages_path（通常はメッセージ一覧を表示するページ）にリダイレクトされます。

（2）のindexアクションは、保存されたメッセージの一覧を表示するためのものです。このアクションは主に以下の動作を行います：

セッションからメッセージの取得: session[:messages]からメッセージの配列を取得し、@messagesインスタンス変数に格納します。この変数はビューで使用され、保存されているメッセージがユーザーに表示されます。

ビューへのデータ渡し: @messagesをビューに渡すことで、ユーザーがこれまでに交わした会話を一覧表示できるようになります。

セッションは、ユーザーがウェブサイトをナビゲートする間、状態（state）やユーザー固有のデータをサーバー側で保持するためのメカニズムです。Railsアプリケーションでは、セッションは通常、ユーザーのブラウザとサーバー間の接続を識別する一時的なクッキーによって管理されます。このクッキーを使って、ログイン情報、購入カートの内容、またはこのケースのようなチャットの会話履歴など、ユーザー固有の情報を記録します。

このチャットアプリケーションのコンテキストでは、セッションを使用してユーザーとチャットボット間の会話の連続性を維持し、ページのロード間で情報を失わないようにします。これにより文脈を保ったままの対話を実現できます。

（3）のclear_sessionアクションは、チャットボットとの対話履歴をクリアし、セッションからメッセージの情報を完全に削除するためのアクションです。このアクションは通常、ユーザーが会話をリセットしたい場合や、新しい対話を完全に新たな状態から始めたいときに使用されます。

 以上で、Messagesコントローラーの説明は完了です。次は、ルーティングを修正するために、「config/routes.rb」を開いて、次のコードに書き換えます。

チャット画面：routes.rb
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root 'messages#index'
  get 'messages', to: 'messages#index'
  post 'messages', to: 'messages#create'
  post 'messages/clear', to: 'messages#clear_session', as: 'messages_clear_session'
  get 'clear_session', to: 'messages#clear_session'
end

copy
config/routes.rbという名前のファイルは、URLの構造を定義するファイルです。ここで定義されたルーティングに従って、リクエストが適切なコントローラーとアクションに割り当てられます。

上記のコードでは、以下のルーティングが定義されています：

root 'messages#index': アプリケーションのルートURL（例: http://localhost:3000/）にアクセスすると、`MessagesController`の`index`アクションが呼び出されます。

get 'messages', to: 'messages#index': /messagesというURLにGETリクエストが送られると、MessagesControllerのindexアクションが呼び出されます。

post 'messages', to: 'messages#create': /messagesというURLにPOSTリクエストが送られると、MessagesControllerのcreateアクションが呼び出されます。これは通常、フォームのサブミット時に使用されます。

post 'messages/clear', to: 'messages#clear_session': /messages/clearというURLにPOSTリクエストが送られると、MessagesControllerのclear_sessionアクションが呼び出されます。

get '/clear_session', to: 'messages#clear_session', as: 'clear_session': /clear_sessionというURLにGETリクエストが送られると、MessagesControllerのclear_sessionアクションが呼び出されます。as: 'clear_session'オプションにより、このルーティングにclear_session_pathというヘルパーメソッドが割り当てられます。これにより、ビューやコントローラーでclear_session_pathを使ってこのURLを参照できるようになります。

以上で、アプリケーションのURLとコントローラーのアクションの対応関係が定義されました。

次は、チャットボット画面のビューを作成します。「app/views/messages/index/html/erb」を開いて、次のコードに変更します。

チャット画面：index.html.erb
<!-- チャットボット -->
<div id="chat-bot-container">
  <!-- メッセージ表示部分 -->
  <div id="messages">
    <% if @messages %>
      <% @messages.each do |message| %>
        <div class="message <%= message['role'] == 'user' ? 'user' : '' %>">
          <p><%= message['content'] %></p>
        </div>
      <% end %>
    <% end %>
  </div>

  <!-- 入力部分 -->
  <div id="message-form">
    <%= form_with(url: messages_path, local: true, id: 'chat-message-form') do |form| %>
      <%= form.text_field :message, id: 'message_input', placeholder: 'メッセージを入力' %>
      <%= form.submit '送信' %>
      <%= form.submit '削除', formaction: messages_clear_session_path %>
    <% end %>
  </div>
</div>

<!-- ページ内のスクリプト -->
<script>
  // 自動でスクロールする
  document.getElementById('messages').scrollTop = document.getElementById('messages').scrollHeight;

  // セッションの内容をコンソールに出力
  const sessionMessages = <%= @messages ? @messages.to_json.html_safe : 'null' %>;
  console.log('Session Messages:', sessionMessages);
</script>

copy
このindex.html.erbファイルは、Railsアプリケーション内でチャットボットのインタフェースを構成するビューファイルです。HTML構造、Railsの埋め込みRubyコード（ERB）、そしてJavaScriptを組み合わせて、チャットのUIとその機能を提供しています。以下に、ファイルの各部分の詳細な説明を行います。

チャットボットコンテナ

<div id="chat-bot-container">は、チャットインタフェース全体を包含するコンテナです。これにより、スタイリングやスクリプトの適用が容易になります。

メッセージ表示部分

このHTMLコードスニペットは、Railsのform_withヘルパーを使用して、チャットボットのメッセージ入力と送信のためのフォームを作成しています。form_withはRails 5.1以降で導入されたヘルパーで、フォームの作成を簡単にし、Ajax（非同期）と非Ajaxの両方のフォーム送信をサポートします。ここではフォームの具体的な機能と属性、そしてCSRF対策について説明します。

入力部分のフォームの属性

url: messages_path: この属性はフォームのデータが送信されるサーバー側のパスを指定します。messages_pathは、通常、messages#createアクションにマップされています。これにより、入力されたメッセージがPOSTメソッドを使ってそのアクションに送信されます。
local: true: このオプションがtrueに設定されている場合、フォームは標準のHTTPリクエストを使ってデータを送信します（Ajaxではない）。これは、JavaScriptが無効になっている環境でもフォームが機能することを保証します。
id: 'chat-message-form': HTML要素に一意のIDを提供し、CSSスタイリングやJavaScript操作を容易にします。

入力部分のフォームのコンポーネント

<%= form.text_field :message, id: 'message_input', placeholder: 'メッセージを入力' %>: ユーザーがメッセージを入力できるテキストフィールドを生成します。:messageはこのフィールドが送信するパラメータの名前を指定し、placeholder属性はユーザーに対してフィールドの用途を示すヒントを提供します。
<%= form.submit '送信' %>: ユーザーがフォームを送信できるボタンを生成します。このボタンをクリックすると、フォームに入力されたデータがmessages_pathで指定されたURLにPOSTされます。
<%= form.submit '削除', formaction: messages_clear_session_path %>: 別の送信ボタンを生成し、このボタンには特別なformaction属性があります。この属性は、ボタンがクリックされた際にフォームデータが送信される別のURLを指定します。messages_clear_session_pathは通常、セッションからメッセージデータを削除するアクションにマップされています。

CSRF対策

このフォームはform_with( local: true)を設定しており、Railsが自動的に生成するCSRFトークンをフォームに含めています。これにより、フォームを介して行われるリクエストが実際にユーザー自身によって意図されたものであり、サイト間リクエスト偽造攻撃によるものではないことをRailsが検証できるようになります。これは、Webアプリケーションにおけるセキュリティの重要な側面であり、ユーザーのセッションを保護する上で欠かせません。

ページ内のスクリプト

<script>タグ内のJavaScriptは、ページがロードされた際にメッセージ表示エリアを自動でスクロールし、最新のメッセージが表示されるようにします。

document.getElementById('messages').scrollTop = document.getElementById('messages').scrollHeight;は、messagesエリアのスクロール位置を最下部に設定します。

セッション内のメッセージをコンソールに出力するコードは、開発時のデバッグや確認を助けるために使用されます。

このビューファイルは、チャットアプリケーションのフロントエンド部分の主要な要素を網羅しており、ユーザーインタラクションとバックエンド間の橋渡しを行います。

以上で、ユーザーとボットのメッセージをブラウザで表示できるようになります。このメッセージをLINE風に表示できるようにするために、以下のようなスタイルを適用します。

メッセージは角丸の枠で囲まれる

ユーザーのメッセージは画面の右側に、ボットのメッセージは画面の左側に表示される

入力エリアは画面の下部に表示される

これらの見た目を実現するために、「app/assets/stylesheets/application.css」を次のコードに修正します。

チャット画面：application.css
/*
 * This is a manifest file that'll be compiled into application.css, which will include all the files
 * listed below.
 *
 * Any CSS (and SCSS, if configured) file within this directory, lib/assets/stylesheets, or any plugin's
 * vendor/assets/stylesheets directory can be referenced here using a relative path.
 *
 * You're free to add application-wide styles to this file and they'll appear at the bottom of the
 * compiled file so the styles you add here take precedence over styles defined in any other CSS
 * files in this directory. Styles in this file should be added after the last require_* statement.
 * It is generally better to create a new file per style scope.
 *
 *= require_tree .
 *= require_self
 */

#chat-bot-container {
    width: 100%;
    max-width: 900px;
    height: 100vh;
    margin: 0 auto;
    background-color: #f4f4f4;
    border-radius: 10px;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    overflow: hidden;
    display: flex;
    flex-direction: column;
}

#messages {
    flex: 1;
    overflow-y: auto;
    padding: 20px;
}

.message {
    max-width: 80%;
    width: fit-content;
    margin-bottom: 10px;
    padding: 10px;
    border-radius: 5px;
    background-color: #ffffff;
}

.message.user {
    margin-left: auto;
    background-color: #e1f5fe;
}

.message p {
    margin: 0;
    word-wrap: break-word;
}

#message-form {
    padding: 20px;
    background-color: #ffffff;
}

#chat-message-form {
    display: flex;
    align-items: center;
}

#message_input {
    flex: 1;
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 5px;
    margin-right: 10px;
}

input[type="submit"] {
    padding: 10px 20px;
    background-color: #4caf50;
    color: #ffffff;
    border: none;
    border-radius: 5px;
    cursor: pointer;
}

input[type="submit"][formaction="/messages/clear"] {
    background-color: #f44336;
    margin-left: 10px;
}

copy
このCSSコードは、Webページ上のチャットボットインターフェースのスタイルを定義しています。具体的には、以下のようなデザイン要素とスタイリングを提供しています：

#chat-bot-container
チャットボットのメインコンテナーを定義しています。
width: 100% と max-width: 900px でコンテナの幅を制限し、コンテンツが適切に表示されるようにしています。
height: 100vh でビューポートの全高を使用し、全画面のレイアウトを実現しています。
margin: 0 auto で中央に配置します。
background-color, border-radius, および box-shadow で背景色、角の丸み、影を設定し、見た目を美しくしています。
display: flex と flex-direction: column で子要素を縦に並べています。

#messages
メッセージが表示される部分で、flexboxのプロパティ flex: 1 を使用して他の要素とのバランスを取りながら、利用可能なスペースを最大限に活用しています。
overflow-y: auto により、メッセージの量が多くなった際にスクロールバーが表示されます。

.message
個々のメッセージをスタイリングします。
メッセージは最大幅 max-width: 80% に制限され、内容に応じて幅が調整されます (width: fit-content)。
背景色とパディングでメッセージが読みやすくなっています。

.message.user
ユーザーからのメッセージに特有のスタイルを適用し、右寄せ (margin-left: auto) と異なる背景色で区別しています。

#message-form
メッセージ入力フォームのコンテナをスタイリングし、背景色とパディングを設定しています。

#chat-message-form
フォーム自体をフレックスボックスとして設定し、アイテムを中央揃えにしています。

#message_input
メッセージ入力フィールドをスタイリングし、フレックスアイテムとして設定して、利用可能なスペースを最大限に活用しています。

input[type="submit"]
送信ボタンの見た目をカスタマイズし、緑色の背景と白文字で目立つようにしています。

input[type="submit"][formaction="/messages/clear"]
削除ボタン（セッションクリア用）には赤色の背景を設定し、送信ボタンとの視覚的な区別をつけています。

これらのスタイルにより、LINE風のユーザーフレンドリーで視覚的に魅力的なチャットインターフェースが提供され、ユーザーは快適にコミュニケーションを行うことができます。

以上で、コードの修正は完了しました。Railsアプリケーションをデバッグしましょう。ターミナルに「rails s」コマンドを入力して、Railsアプリケーションを起動します。入力フィールドに自由にテキストを入力して、「送信」してみます。

チャット画面：デバッグ
画像
図7 LINE風チャットボット
図7は、Railsアプリケーションの起動画面です。入力フィールドに入力した文字列がそのまま返信として返ってくることが確認できました。また、削除ボタンをクリックして、メッセージを削除できることも確認しておきましょう。以上で、チャット画面の作成過程は終了です。

次の作業は、ここまでの修正をコミットとして保存することです。コードを修正したら、適当な粒度でこまめにコミットすることで、開発効率を上げることができます。また、他の開発者にコードを見てもらうときに理解しやすくなります。コミットは次の手順で行います。

チャット画面：コミット
画像
図8 コミット
Codespaces（VS Code）の右サイドメニューからGitを選んでください。変更セクションの「+」をクリックして、コードの変更をステージングします。入力フィールドにコミットメッセージ「LINE風のチャット画面の作成」を入力して、「コミット」ボタンをクリックして、コミットを確定します。ステージングセクションのファイルが消えたら、コミットは成功です。

次は、このコミットをGitHubのmainブランチにプッシュします。

チャット画面：プッシュ
画像
図9 mainブランチにプッシュ
コミットの後、ボタンの表示が「変更の同期」に変わっているはずです。この「変更の同期」ボタンをクリックすると、確認のダイアログが表示されるので「OK」を選びます。以上で、GitHubのmainブランチにコードの修正が反映されます。これで、第2部の作業は全て終了です。

ここまでの実装では、送った文字列がそのまま返信として返ってきます。この返信部分をカウンセラー役の応答文に変更するには、生成AIのAPIサービスを使用します。次の第3部では、生成AIとの連携について詳しく解説していきます。

第3部　生成AI連携
第2部では、Railsアプリケーションを使ってチャットボットのユーザーインターフェースを実装しました。しかし、現状では、ユーザーの入力をそのまま返信として表示するだけの簡易的な実装になっています。真のチャットボットを作成するには、ユーザーの質問に対して intelligent な返答を生成する必要があります。

ここで、生成AIの出番です。生成AIを活用することで、我々のチャットアプリは、ユーザーの質問に対して知的でインタラクティブな返答を提供できるようになります。ユーザーは、まるで人間のカウンセラーと会話をしているかのような体験を得ることができるでしょう。

生成AIを使うためには、APIを介して通信を行う必要があります。APIとは、Application Programming Interfaceの略で、異なるソフトウェア間でデータをやり取りするための仕組みです。生成AIとのAPI連携を行うことで、我々のアプリケーションから生成AIにデータを送信し、その返答を受け取ることができます。

次のセクションでは、生成AIのAPIを利用するための準備として、OpenAIのアカウント作成とAPIキーの取得方法について説明します。その後、Anthropic（Claudeのサービスプロバイダー）、Google AI Studio（Geminiのサービスプロバイダー）のアカウント作成とAPIキーの作成を行います。

OpenAI APIキーの作成
OpenAI APIキーを作成するには、以下の手順を実行します。次に示す図は、OpenAIのウェブサイトで新しいAPIキーを作成している様子です。Nameとして、用途や分類を登録しておくと、APIキーの管理に役立ちます。

画像
図10 OpenAI APIキーの作成
OpenAIのウェブサイト（https://openai.com/）にアクセスし、アカウントを作成またはログインします。

ダッシュボードにアクセスし、「API keys」セクションに移動します。

「Create new secret key」ボタンをクリックして、新しいAPIキーを生成します。

生成されたAPIキーをコピーし、安全な場所に保存します。このキーは後で使用するので、忘れないようにしてください。

APIキーを作成したら、アプリケーションからChatGPT APIを呼び出すことができます。次に、Anthropic APIキーとGoogle AI APIキーの作成手順を説明します。

Anthropic APIキーの作成
Anthropic APIキーを作成するには、以下の手順を実行します。次の図は、Anthropicのウェブサイトで新しいAPIキーを作成している様子です。Nameとして、用途や分類を登録しておくと、APIキーの管理に役立ちます。

画像
図11 Anthropic APIキーの作成
Anthropicのウェブサイト（https://www.anthropic.com/）にアクセスし、アカウントを作成またはログインします。

ダッシュボードにアクセスし、「API」セクションに移動します。

「Generate API Key」ボタンをクリックして、新しいAPIキーを生成します。

生成されたAPIキーをコピーし、安全な場所に保存します。

Google AI APIキーの作成
Google AI APIキーを作成するには、以下の手順を実行します。初回のAPIキー作成時には、新しいGCP（Google Cloud Platform）プロジェクトを作成する必要があります。2回目以降のAPIキー作成時には、次の図に示すように既存のプロジェクト「Generative Language Client」を選択してください。

画像
図12 Google AI APIキーの作成
Google Cloud Platformのウェブサイト（https://console.cloud.google.com/）にアクセスし、アカウントを作成またはログインします。

Google AI Studioのウェブサイト（https://aistudio.google.com/）にアクセスして、左サイドバーから「Get API Key」セクションを選びます。

「Create API Key in new project」を選択します（初回のみ）。

生成されたAPIキーをコピーし、安全な場所に保存します。

2つ目以降のAPIキーを作成するときは、「Create API Key」から、プロジェクト名「Generative Language Client」を選んでください。現時点では、APIキーに識別のための名前をつけることはできないので、作成したキーの用途などを別途メモしておくことをおすすめします。

これで、3つの生成AIのAPIキーが作成されました。次に、APIキーの取り扱いについての注意事項を説明します。

APIキーを秘匿情報として保護する方法
APIキーを含む秘匿情報を直接Railsアプリに組み込むことは避けるべきです。なぜなら、Railsアプリのソースコードはバージョン管理システムで共有されるため、APIキーが開発者に公開されてしまう可能性があるからです。これは、セキュリティ上の大きなリスクになります。APIキーが不正に利用され、多額の支払いが発生する可能性があります。

そこで、APIキーなどの秘匿情報を安全に管理する方法として、Rails 5.2から導入されたcredentials.yml.encを使用することをお勧めします。

credentials.yml.encにAPIキーを保存
credentials.yml.encは、AES-128-GCMアルゴリズムを使用して暗号化されたファイルで、APIキーなどの秘匿情報を安全に保存することができます。このファイルは、Railsアプリケーションのルートディレクトリに配置され、config/credentials.yml.encというパスで参照されます。

ただし、現在プロジェクトに含まれているconfig/credentials.yml.encは、テンプレートから新しいレポジトリを作成する過程で、対応するmaster.keyが失われている可能性があります。master.keyは、credentials.yml.encを復号化するために必要な鍵ファイルで、Gitの管理外に置かれます。そのため、古いconfig/credentials.yml.encファイルは削除して構いません。次に示す手順で、新しいmaster.keyとcredentials.yml.encファイルが生成されます。

暗号化されたファイルを編集するには、rails credentials:editコマンドを使用します。このコマンドを実行すると、エディタが開き、復号化された内容を編集することができます。編集が完了すると、ファイルは自動的に再暗号化され、保存されます。Vimエディターを使うときのコマンドは次のようになります。

$ EDITOR=vim rails credentials:edit

copy
画像
図13 秘匿情報を保存する
ターミナルで開いたcredentials.yml.encに、以下のような形式でAPIキーを保存します。

# OpenAI API Service
openai:
  api_key: sk-xxxxxxxxxxxxxxxxxxxx
# Anthropic API Service
anthropic:      
  api_key: sk-xxxxxxxxxxxxxxxxxxxxx
google:         
  api_key: xxxxxxxxxxxxxxxxxxxxx


copy
上記の例では、openaiの下に、api_keyとしてOpenAI APIキーの文字列（sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx）を保存しています。同様に、AnthropicとGoogleのAPIキーを保存します。

Vimエディタの最低限の使い方
Vimエディタは、ターミナル上で動作するテキストエディタです。以下に、Vimエディタの最低限の使い方を示します。

① iキー：インサートモード（編集モード）に入ります。このモードでテキストを入力・編集できます。
② Escキー：インサートモードから抜けて、ノーマルモードに戻ります。
③ :wq：ファイルを保存して終了します。
④ :q!：ファイルを保存せずに終了します。

以上の4つのコマンドを覚えておけば、Vimエディタで基本的な編集作業を行うことができます。

Railsアプリケーション内でcredentials.yml.encに保存された秘匿情報にアクセスするには、以下のようにします。

api_key = Rails.application.credentials.openai[:api_key]

copy
この方法により、APIキーがソースコード内に直接記述されることがなくなり、セキュリティリスクを軽減することができます。

ただし、credentials.yml.encファイルをGitリポジトリで管理する場合は、いくつか注意点があります。

credentials.yml.encファイルは、暗号化されているため、Gitリポジトリにコミットしても安全です。ただし、config/master.keyファイル（暗号化されたファイルを復号化するための鍵が記載されたファイル）は、Gitリポジトリにコミットしないようにする必要があります。.gitignoreファイルにconfig/master.keyを追加して、Gitの管理対象から除外しましょう。

本番環境では、config/master.keyファイルを別の方法で管理する必要があります。Renderなどのクラウドプラットフォームでは、環境変数を使用してmaster.keyの内容を設定することができます。

以上が、Rails 5.2以降で導入されたcredentials.yml.encを使用したAPIキーの秘匿方法の説明です。この方法を使用することで、APIキーを安全に管理し、不正利用のリスクを軽減することができます。

以上の作業で、生成されたmaster.keyには32文字のランダム英数字が記載されています。この文字列は、第4部でRenderのビルド設定に必要なのでメモしておいてください。

次は、OpenAIのAPIを簡単に使えるようにしてくれる「ruby-openai」gemをインストールします。同時に、AnthropicとGoogle AI用のgemもインストールしておきます。Gemfileに次の行を追記します。

ChatGPT連携：3つの生成AIのgemをまとめてインストール

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# 追記部分
# ChatGPT
gem 'ruby-openai'
# Claude
gem "anthropic"
# Gemini
gem "ruby-gemini-ai"
# 追記部分終わり

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
end

copy
Gemfileの修正が終わったら、ターミナルで次のコマンドを実行して、gemをインストールし直します。

$ bundle install

copy
以上で、生成AIのgemのインストールが完了しました。次は、ChtGPT APIを使って、ユーザーの質問に答えるクラスを作成します。appフォルダーの中に「services」というフォルダーを作ります。そのservicesフォルダーの中に「chatgpt_service.rb」という名前のファイルを作成して、次のコードを記載します。

ChatGPT連携：ChatgptServiceクラス
ここから先は有料部分です
require 'openai'

class ChatgptService
  def self.generate_response(messages)
    client = OpenAI::Client.new(access_token: Rails.application.credentials.openai[:api_key]) # （1）
    system_content = <<~TEXT # （2）
        あなたはスクールカウンセラーです。
        生徒からの相談を受けています。
        生徒の話を受容と共感を持って聞くことが大切です。
        生徒との会話は一方通行ではなく、生徒の話に対して適切な質問を投げかけることで、
        生徒が自分の問題に気づくように導いてください。
        会話は概ね5ターン以内で終了するように、まとめて下さい。
        また、生徒の話が「ありがとう」や「さようなら」で終わった時は、
        生徒が納得したか確認して、生徒がこの話題を終了するように促してください。
        生徒が「終了」「ストップ」と言ったときは、会話を終了してください。
        あなたの回答は100文字以内にしてください。
    TEXT
    system_prompt = [{ 'content' => system_content, 'role' => 'system'}]

    response = client.chat( # （3）
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: system_prompt + messages
      }
    )

    if response.dig('error', 'message') # （4）
      return "Error: #{response['error']['message']}"
    else
      response.dig('choices', 0, 'message', 'content')
    end
  end
end

copy
このChatgptServiceクラスは、会話履歴のリストからChatGPT APIを使ってカウンセラーとしての回答を作成します。OpenAI APIを活用した対話型アプリケーションの基本的なフレームワークを示しており、Ruby on RailsアプリケーションでAIを利用する際の良い出発点になります。コメント番号部分を解説します。

（1）では、OpenAI::Client オブジェクトを初期化しています。new メソッドに渡されている access_token は、Railsアプリケーションのクレデンシャル（認証情報）から取得しています。ここで使用されている Rails.application.credentials.openai[:api_key] は、Railsの暗号化されたクレデンシャルファイルに保存されているAPIキーを参照しており、これを使ってOpenAI APIへの認証を行います。

（2）で使用されているのはヒアドキュメント（here-document）と呼ばれる構文で、長い文字列や複数行にわたるテキストを直接コード内に埋め込む際に使います。<<~ はインデントを無視したヒアドキュメントの開始を示しており、TEXT が閉じタグです。この間に書かれたテキストは、system_content 変数に文字列として格納されます。

（3）は、初期化されたOpenAIクライアントを通じてChat APIを呼び出しています。model: 'gpt-3.5-turbo' で使用するAIモデルを指定し、messages パラメータには system_prompt（先程設定したプロンプト）とユーザーからのメッセージが結合された配列を渡しています。APIからは応答が response 変数に格納されます。

（4）では、APIの応答をチェックしてエラーが含まれているかどうかを確認しています。response.dig('error', 'message') は、応答内のエラーメッセージを安全に取得するために使用されています。もしエラーメッセージが存在すれば、その内容を含む文字列を返します。エラーがない場合、応答から実際の回答を抽出して返します。

以上で、ChatgptServiceクラスの説明を終了します。次は、MessagesController.rbを改造して、エコースキル（そのまま返す）をカウンセラーボットにアップデートします。次に示すコードの追加部分だけを修正します。

ChatGPT連携：MessagesControllerクラスの編集
class MessagesController < ApplicationController
  def create
    unless params[:message].empty?
      # 省略...


      # # エコーチャットボット
      # assistant_response = params[:message] # （1）
      assistant_response = ChatgptService.generate_response(messages) # （2）

      messages << { 'content' => assistant_response, 'role' => 'assistant' }

    # 省略...

copy
このコードは、返信メッセージを保存するassistant_message変数をChatGPT APIの応答文に変更する箇所を示しています。

（1）は、入力文をそのまま返すエコーアプリを実装しているため、コメントにして無効にします。そして、（2）で、ChatGPT APIからの応答文をアシスタントメッセージとして取得するコードを追記します。

以上で、ChatGPT連携の作業は終了です。サーバーが起動中なら、「Ctrl + C」で停止して、rails sコマンドでRailsアプリケーションを再起動します。動作チェックをしてみましょう。

ChatGPT連携：デバッグ
画像
図14 ChatGPTからの応答を取得できた
Railsアプリケーションを起動してから、入力フィールドに質問を入力して「送信」ボタンをクリックします。第2部とは違って、ChatGPTからの応答が返信メッセージとして表示されるようになりました。システムプロンプトで与えた共感的カウンセラーとしての回答を表示させることに成功しました。次は、Claudeとの連携を実装します。app/servicesフォルダーの中に「claude_service.rb」という名前のファイルを作成して、次のコードを記載します。

Claude連携：ClaudeServiceクラス
require 'anthropic'

class ClaudeService
  def initialize
    @client = Anthropic::Client.new(access_token: Rails.application.credentials.anthropic[:api_key]) # （1）
  end

  def self.generate_response(messages)
    system_content = <<~TEXT
        あなたはスクールカウンセラーです。
        生徒からの相談を受けています。
        生徒の話を受容と共感を持って聞くことが大切です。
        生徒との会話は一方通行ではなく、生徒の話に対して適切な質問を投げかけることで、
        生徒が自分の問題に気づくように導いてください。
        会話は概ね5ターン以内で終了するように、まとめて下さい。
        また、生徒の話が「ありがとう」や「さようなら」で終わった時は、
        生徒が納得したか確認して、生徒がこの話題を終了するように促してください。
        生徒が「終了」「ストップ」と言ったときは、会話を終了してください。
        あなたの回答は100文字以内にしてください。
    TEXT

    response = @client.messages( # （2）
      parameters: {
        model: "claude-3-opus-20240229",
        system: system_content,
        messages: messages,
        max_tokens: 1000
      }
    )

    if response.dig('error', 'message') # （3）
      return "Error: #{response['error']['message']}"
    else
      response.dig('content', 0, 'text')
    end
  end
end

copy
ClaudeServiceクラスは、Claude APIを使って、会話履歴からカウンセラーとしての回答を取得します。

（1）では、Anthropic社のAPIを利用するためのクライアントオブジェクトを初期化しています。Anthropic::Client.new に渡される access_token は、Railsの暗号化されたクレデンシャルファイルに保存されているAPIキーを使用しており、これによってAPIへの認証を行います。このステップはAPIを利用する上でのセキュリティを保証し、有効な認証情報を通じてサービスへのアクセスを許可します。

（2）では、client.messages メソッドを呼び出し、APIへパラメータと共にリクエストを送信しています。ここで使用されているパラメータは以下の通りです：

model: 使用するAIモデルの識別子です。ここでは "claude-3-opus-20240229" モデルが指定されています。

system: システムによって事前に設定されたプロンプトや指示文です。ヒアドキュメントで定義された長文がここに渡されます。

messages: ユーザーからのメッセージの配列。この情報を基にAIが応答を生成します。

max_tokens: 生成される応答の最大トークン数。これにより、応答の長さを制御します。

（3）では、APIからの応答を評価しています。response.dig('error', 'message') を使用して、応答からエラーメッセージを安全に抽出し、エラーがある場合はそのメッセージを返します。エラーがない場合は、response.dig('content', 0, 'text') を使って応答内容の最初のテキストを抽出し、それを返します。これにより、APIの応答から適切なデータのみを取り出し、利用することができます。

以上で、ClaudeServiceクラスの説明を終わります。次は、MessagesControllerクラスを修正して、Claudeと会話できるようにします。

Claude連携：MessagesControllerクラスの修正
class MessagesController < ApplicationController
  def create
    unless params[:message].empty?
      # 省略...


      # # エコーチャットボット
      # assistant_response = params[:message]
      # assistant_response = ChatgptService.generate_response(messages) # （1）
      assistant_response = ClaudeService.generate_response(messages) # （2）

      messages << { 'content' => assistant_response, 'role' => 'assistant' }

    # 省略...

copy
このコードは、assistant_message変数をClaude APIの応答文を代入しています。

（1）は、ChatGPT APIから回答を得るための実装しているため、コメントにして無効にします。そして、（2）で、Claude APIからの応答文をアシスタントメッセージとして取得するコードを追記します。

MessagesControllerクラスの修正が終わったら、動作チェックをします。サーバーが起動中なら、「Ctrl + C」で停止して、rails sコマンドでRailsアプリケーションを再起動します。Claudeとの会話を次の図に示します。

画像
図15 Claudeとの対話
図15は、Claudeをカウンセラー役として、学生との対話を再現したものです。これで、Claude連携は完了です。第3部の最後に、Geminiとの連携を実装します。app/servicesフォルダーの中に「gemini_service.rb」という名前のファイルを作成して、次のコードを記載します。

Gemini連携：GeminiServiceクラス
require 'gemini-ai'

class GeminiService
  def self.generate_response(messages)
    client = GeminiAi::Client.new(api_key: Rails.application.credentials.google[:api_key]) # （1）
    system_content = <<~TEXT
        あなたはスクールカウンセラーです。
        生徒からの相談を受けています。
        生徒の話を受容と共感を持って聞くことが大切です。
        生徒との会話は一方通行ではなく、生徒の話に対して適切な質問を投げかけることで、
        生徒が自分の問題に気づくように導いてください。
        会話は概ね5ターン以内で終了するように、まとめて下さい。
        また、生徒の話が「ありがとう」や「さようなら」で終わった時は、
        生徒が納得したか確認して、生徒がこの話題を終了するように促してください。
        生徒が「終了」「ストップ」と言ったときは、会話を終了してください。
        あなたの回答は100文字以内にしてください。
    TEXT

    # Geminiの仕様に合わせて、contentsを作成
    gemini_contents = messages.each_with_index.map do |message, index| # （2）
      # 最初のメッセージの場合、システムプロンプトを追加
      if index == 0
        parts_text = "#{system_content} ユーザーのメッセージは次の通りです。「#{message['content']}」"
      else
        parts_text = message['content']
      end
      puts parts_text

      # メッセージのロールに基づいてroleを設定
      role = message['role'] == 'assistant' ? 'model' : message['role']
      puts role

      # 返却するハッシュの構造
      { 'role' => role, 'parts' => { 'text' => parts_text } }
    end
    # puts "gemini_contents: " + gemini_contents.to_s


    contents = {
      contents: gemini_contents
    }

    response = client.generate_content(contents, model: "gemini-pro") # （3）

    if response.dig('error', 'message') # （4）
      return "Error: #{response['error']['message']}"
    else
      response.dig('candidates', 0, 'content', 'parts', 0, 'text')
    end
  end
end

copy
GeminiServiceクラスは、Gemini APIを使って、会話履歴からカウンセラーとしての回答を取得します。

（1）では、Gemini APIを利用するためのクライアントオブジェクトを初期化しています。GeminiAi::Client.new に渡される api_key は、Railsの暗号化されたクレデンシャルファイルに保存されているAPIキーを使用しており、これによってAPIへの認証を行います。このステップはAPIを利用する上でのセキュリティを保証し、有効な認証情報を通じてサービスへのアクセスを許可します。

（2）で、Gemini APIの仕様に基づいて、APIリクエストデータを再構築しています。ChatGPTとClaudeはほぼ同じ形式ですが、Geminiは大きく異なるため、データ整形に手間がかかります。特にシステムプロンプトを応答に反映させる実装は提供されていないため、ユーザーの最初のメッセージにシステムプロンプトを合体させるという代替手段をとっています。

（3）では、client.generate_content メソッドを呼び出し、APIへパラメータと共にリクエストを送信しています。会話履歴であるcontentsとモデル名「gemini-pro」を引数として渡します。

（4）では、APIからの応答を評価しています。response.dig('error', 'message') を使用して、応答からエラーメッセージを安全に抽出し、エラーがある場合はそのメッセージを返します。エラーがない場合は、response.dig('candidates', 0, 'content', 'parts', 0, 'text')を使って応答内容の最初のテキストを抽出し、それを返します。これにより、APIの応答から適切なデータのみを取り出し、利用することができます。

以上で、GeminiServiceクラスの説明を終わります。次は、MessagesControllerクラスを修正して、Geminiと会話できるようにします。

Gemini連携：MessagesControllerクラスの修正
class MessagesController < ApplicationController
  def create
    unless params[:message].empty?
      # 省略...


      # # エコーチャットボット
      # assistant_response = params[:message]
      # assistant_response = ChatgptService.generate_response(messages)
      # assistant_response = ClaudeService.generate_response(messages) # （1）
      assistant_response = GeminiService.generate_response(messages) # （2）

      messages << { 'content' => assistant_response, 'role' => 'assistant' }

    # 省略...

copy
このコードは、assistant_message変数にGemini APIの応答文を格納します。

（1）は、Claude APIから回答を得るための実装しているため、コメントにして無効にします。そして、（2）で、Gemini APIからの応答文をアシスタントメッセージとして取得するコードを追記します。

MessagesControllerクラスの修正が終わったら、動作チェックをします。サーバーが起動中なら、「Ctrl + C」で停止して、rails sコマンドでRailsアプリケーションを再起動します。Geminiとの会話を次の図に示します。

画像
図16 Geminiとの対話
図16は、Geminiをカウンセラー役として、学生との対話を再現したものです。これで、Gemini連携は完了です。第3部では、3つの生成AI（ChatGPT、Claude、Gemini）との連携を実装できました。ここで学んだ実装を応用すれば、他の生成AIとの連携も実装できるはずです。

ただし、現時点で作成したコードは、3つの生成AIのうち1つを固定して使用することを前提としています。つまり、ユーザーが生成AIの種類を自由に変更できる機能は含まれていません。

生成AIの切り替え機能を実装するには、さらなる工夫が必要です。例えば、ユーザーからの特定のキーワードを受け取ったときに、使用する生成AIを動的に変更するロジックを追加する必要があります。

このような切り替え機能の実装は、本記事の目的である「簡単に生成AI連携アプリを作成する」からは外れてしまうため、今回は省略することにしました。以上で、第3部の生成AI連携は完了です。

第2部と同じように、プロジェクトの変更部分を「ステージング > コミット > プッシュ」しておきます。コミットメッセージは「生成AI連携を実装」としておいてください。この操作により、次の第4部でRenderにデプロイして外部への公開が可能になります。

第4部　Renderにデプロイ
第4部では、完成したRailsアプリケーションをRenderにデプロイして、インターネット上で公開する方法を説明します。

Renderとは
Renderは、Webアプリケーションやバックエンドサービスをデプロイするためのクラウドプラットフォームです。シンプルで使いやすいインターフェースを提供し、GitHubとの連携も容易であるため、多くの開発者に利用されています。

Renderにデプロイすることで、以下のようなメリットがあります。

スケーラビリティ：アプリケーションのトラフィックに応じて、自動的にインスタンスの数を調整できます。

HTTPS対応：SSL/TLS証明書を自動的に設定し、アプリケーションをHTTPS対応にできます。

CI/CD：GitHubと連携することで、コードの変更を自動的にデプロイできます。

無料プラン：一定の制限はありますが、無料でアプリケーションをデプロイできます。

それでは、RenderにRailsアプリケーションをデプロイする手順を見ていきましょう。

Renderアカウントの作成
Renderにアプリケーションをデプロイするには、まずRenderのアカウントを作成する必要があります。以下の手順に従って、アカウントを作成しましょう。

Renderの公式サイト（https://render.com/）にアクセスします。

画面右上の「Sign Up」ボタンをクリックします。

「Sign Up」ページで、以下のいずれかの方法を選択してアカウントを作成します。

GitHubアカウントを使用してサインアップ：「Sign up with GitHub」ボタンをクリックし、GitHubアカウントの認証を完了します。

アカウント作成が完了すると、Renderのダッシュボードが表示されます。

これで、Renderのアカウントが作成されました。次のセクションでは、実際にRailsアプリケーションをRenderにデプロイする手順を説明します。

Renderにデプロイ
Renderのアカウントを作成したら、以下の手順に従ってRailsアプリケーションをデプロイしましょう。

画像
図17 Renderダッシュボード
Renderのダッシュボードで、「New +」ボタンをクリックし、ドロップダウンメニューから「Web Service」を選択します。

画像
図18 Gitレポジトリからデプロイ
Create a new Web Service画面で「Build and deploy from a Git repository」を選びます。

画像
図19 レポジトリを検索
Connect a repositoryセクションで、レポジトリ名で検索します。対象のレポジトリが見つかったら「Connect」で決定します。

画像
図20 ビルドの設定
ビルドの設定画面が表示されます。Runtimeとして「Ruby」を選ぶと自動的にBuild CommnadとStart Commnadが入力されます。これらコマンドは初期値のままで結構です。Instance Typeは「Free」を選びます。最後にEnvironment VariablesでRAILS_MASTER_KEYとして、第3部でメモしたmaster.keyの文字列を入力します。以上で設定は完了します。「Create Web Service」をクリックします。

画像
図21 ビルド&デプロイの完了
ビルドプロセスが進行するので、しばらく待機します。「Your service is live」の表示が出たら、ビルド&デプロイは完了です。左上の公開URLをクリックして、デプロイしたRailsアプリをチェックできます。

画像
図22 デプロイしたRailsアプリ
デプロイしたアプリをデバッグします。質問に対してカウンセラーとしての回答を取得できています。カウンセラーボットに日頃の悩みを打ち明けてみましょう。何かヒントが得られるかもしれません。

最後に、デプロイしたサービスを一時停止する方法を解説します。RenderのFreeプランは料金はかかりませんが、ChatGPT APIは有料サービスです。悪意ある利用により多額の支払いが発生する可能性があります。よって、不要になったら、サービスを一時停止（または削除）しておきましょう。

サービスの停止・削除
画像
図23 サービスの一時停止
サービスの停止方法を解説します。Renderの左メニュー「Settings」を選びます。スクロールして一番下にある「Suspend Web Service」をクリックすると、サービスが停止します。「Delete Web Service」でサービスが削除されます。これらの操作を忘れないように実行しておきましょう。これで、Renderの説明を終了します。

アプリのテストが終了したら、OpenAI、Anthropic、Google AI Studioのサイトにログインして、APIキーを無効化（キーを再生成するか、削除）しておきましょう。こうすることで、APIキーの不正利用を完全に防ぐことができます。

おわりに
本記事では、Ruby on Rails 7を使ってLINE風のチャットボットを作成し、生成AIを利用してカウンセラー機能を実装する方法を紹介しました。記事の内容を通して、以下のようなスキルや知識が身についたのではないでしょうか。

GitHub Codespacesを使った開発環境の構築

Railsを使ったチャット画面の実装

生成AIとの連携方法

Renderを使ったRailsアプリケーションのデプロイ

これらのスキルは、現代のWebアプリケーション開発において非常に重要です。特に生成AIを利用した自然言語処理機能は、今後さまざまな分野で活用されることが期待されています。

本記事では、Railsを使ってチャットボットを作成する過程で、MessagesControllerやルーティングの設定、ビューファイルの作成など、Railsアプリケーション開発の実践的なスキルを学ぶことができました。また、ChatGPT、Claude、Geminiといった生成AIサービスとのAPI連携方法についても詳しく解説しました。これらの知識は、他のAIサービスを利用する際にも応用できるでしょう。

最後になりましたが、本記事を最後まで読んでいただき、ありがとうございました。皆さんのWebアプリケーション開発の一助となれば幸いです。Happy coding!
