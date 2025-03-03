class GenerateBookmarkSummaryWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(bookmark_id)
    bookmark = Bookmark.find(bookmark_id)
    return if bookmark.nil?

    begin
      bookmark.update!(ai_processing_status: :processing)
      
      # OpenAIのAPIを使用してURLの内容を要約
      client = OpenAI::Client.new
      content = fetch_url_content(bookmark.url)
      
      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: "以下のウェブページの内容を3行程度で要約してください：\n#{content}" }],
          temperature: 0.7,
        }
      )

      summary = response.dig("choices", 0, "message", "content")
      bookmark.update!(
        description: summary,
        ai_processing_status: :completed
      )
    rescue => e
      bookmark.update!(ai_processing_status: :failed)
      Rails.logger.error "Bookmark summary generation failed: #{e.message}"
      raise e
    end
  end

  private

  def fetch_url_content(url)
    response = Faraday.get(url)
    doc = Nokogiri::HTML(response.body)
    
    # メタデータとメインコンテンツを取得
    title = doc.at_css('title')&.text || ''
    description = doc.at_css('meta[name="description"]')&.[]('content') || ''
    main_content = doc.at_css('main, article, #main, .main')&.text || doc.at_css('body')&.text || ''
    
    # 内容を結合して返す
    [title, description, main_content].join("\n")[0..1000]
  end
end 