class AiService
  def initialize(mock_mode: ENV['MOCK_AI'] == 'true')
    @mock_mode = mock_mode
    @chat_gpt_service = ChatGptService.new
  end

  def generate_tag_suggestions(url_content)
    if @mock_mode
      generate_mock_suggestions
    else
      generate_real_suggestions(url_content)
    end
  end

  def generate_description(url_content)
    if @mock_mode
      generate_mock_description(url_content)
    else
      generate_real_description(url_content)
    end
  end

  def self.generate_tag_suggestions(prompt)
    # URLからコンテンツを取得
    content = fetch_url_content(prompt.url)
    return [] if content.blank?

    # 既存のタグを取得
    existing_tags = prompt.user.tags.pluck(:name)

    # モックモード確認
    if ENV["MOCK_AI"] == "true"
      Rails.logger.info "Using MOCK_AI mode for tag suggestions"
      return generate_mock_tags(prompt)
    end

    # AI APIにリクエスト
    response = OpenAI::Client.new.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: "あなたはタグ提案AIです。URLの内容に基づいて、適切なタグを5つ提案してください。" },
          { role: "user", content: "以下のコンテンツに適したタグを提案してください。既存のタグ: #{existing_tags.join(', ')}\n\nタイトル: #{prompt.title}\n\nコンテンツ: #{content}" }
        ],
        temperature: 0.7,
        max_tokens: 150
      }
    )

    # レスポンスからタグを抽出
    suggested_tags = parse_tags_from_response(response)

    # タグ候補を保存
    save_tag_suggestions(prompt, suggested_tags)

    suggested_tags
  rescue => e
    Rails.logger.error "Error in AI Service: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    return []
  end

  private

  def generate_real_suggestions(url_content)
    prompt = <<~PROMPT
    以下のウェブページの内容から、適切なタグを5つ提案してください。
    タグは一般的で、検索やカテゴリ分けに役立つものを選んでください。
    各タグには0から1の間の確信度も付けてください。
    
    ウェブページの内容:
    #{url_content}
    
    回答は以下のJSON形式で返してください:
    {
      "tags": [
        {"name": "タグ名", "confidence": 0.9},
        ...
      ]
    }
    PROMPT

    response = @chat_gpt_service.chat(prompt)
    parse_ai_response(response)
  rescue => e
    Rails.logger.error "AI tag generation failed: #{e.message}"
    []
  end

  def generate_mock_suggestions
    [
      { name: "プログラミング", confidence: 0.9 },
      { name: "Ruby", confidence: 0.85 },
      { name: "Web開発", confidence: 0.8 },
      { name: "チュートリアル", confidence: 0.7 },
      { name: "技術ブログ", confidence: 0.6 }
    ]
  end

  def generate_real_description(url_content)
    prompt = <<~PROMPT
    以下のウェブページの内容を100文字程度で簡潔に要約してください。
    要約は日本語で、ウェブページの主要な内容や目的が伝わるようにしてください。
    
    ウェブページの内容:
    #{url_content}
    PROMPT

    @chat_gpt_service.chat(prompt)
  rescue => e
    Rails.logger.error "AI description generation failed: #{e.message}"
    "AIによる説明文の生成に失敗しました。"
  end

  def generate_mock_description(url_content)
    "これはAIによって生成されたモックの説明文です。実際のウェブページの内容に基づいた説明文が生成されます。"
  end

  def parse_ai_response(response)
    parsed = JSON.parse(response)
    parsed["tags"]
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse AI response: #{e.message}"
    []
  end

  def self.generate_mock_tags(prompt)
    # 開発環境用のモックタグ生成
    base_tags = ["Rails", "AI", "開発", "プログラミング", "Ruby", "Web", "API", "フロントエンド", "バックエンド"]
    title_words = prompt.title.downcase.split(/\W+/).reject(&:empty?)
    
    # タイトルから関連しそうなタグを抽出
    related_tags = base_tags.select { |tag| title_words.any? { |word| tag.downcase.include?(word) || word.include?(tag.downcase) } }
    
    # 最低3つ、最大5つのタグを返す
    result = related_tags.take(3)
    result += base_tags.sample(5 - result.size) if result.size < 5
    
    # モックタグを保存
    save_tag_suggestions(prompt, result)
    
    result
  end

  def self.save_tag_suggestions(prompt, tags)
    tags.each_with_index do |tag_name, index|
      # インデックスが小さいほど信頼度が高いと仮定
      confidence = 1.0 - (index * 0.1)
      
      # 既存のタグ候補があれば更新、なければ作成
      TagSuggestion.find_or_create_by(prompt_id: prompt.id, name: tag_name.downcase) do |ts|
        ts.confidence = confidence
        ts.applied = false
      end
    end
  end

  def self.fetch_url_content(url)
    return "" if url.blank?
    
    begin
      response = HTTParty.get(url, timeout: 10)
      return "" unless response.success?

      doc = Nokogiri::HTML(response.body)
      # メタデータとコンテンツを抽出
      title = doc.at_css('title')&.text || ""
      description = doc.at_css('meta[name="description"]')&.[]('content') || ""
      content = doc.css('p').map(&:text).join(" ")[0..1000] # 最初の1000文字を取得

      "#{title}\n#{description}\n#{content}"
    rescue => e
      Rails.logger.error "Error fetching URL content: #{e.message}"
      return ""
    end
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