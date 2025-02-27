class AiSummaryService
  def self.generate_summary(url)
    content = fetch_content(url)
    response = openai_client.chat(
      parameters: {
        model: "gpt-4",
        messages: [
          { role: "system", content: "以下のウェブページの内容を200字程度で要約してください。" },
          { role: "user", content: content }
        ],
        max_tokens: 300
      }
    )
    response.dig("choices", 0, "message", "content")
  rescue => e
    Rails.logger.error("AI概要生成エラー: #{e.message}")
    nil
  end

  private

  def self.fetch_content(url)
    response = Faraday.get(url)
    doc = Nokogiri::HTML(response.body)
    
    # メタデータとコンテンツを取得
    title = doc.at_css('title')&.text
    description = doc.at_css('meta[name="description"]')&.[]('content')
    main_content = doc.css('article, main, .content, #content').text
    
    [title, description, main_content].compact.join("\n\n")
  rescue => e
    Rails.logger.error("コンテンツ取得エラー: #{e.message}")
    "URLからコンテンツを取得できませんでした"
  end

  def self.openai_client
    @client ||= OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end
end 