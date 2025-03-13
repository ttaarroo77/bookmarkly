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
end 