class GenerateBookmarkSummaryWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(bookmark_id)
    bookmark = Bookmark.find_by(id: bookmark_id)
    return unless bookmark

    begin
      bookmark.update(ai_processing_status: :processing)
      
      # ここにAI概要生成のコードを書く
      # 例: OpenAIのAPIを呼び出すなど
      
      bookmark.update(
        description: "このブックマークの説明文はAIによって生成されます。",
        ai_processing_status: :completed,
        ai_processed_at: Time.current
      )
    rescue => e
      Rails.logger.error "AI概要生成エラー: #{e.message}"
      bookmark.update(ai_processing_status: :failed)
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