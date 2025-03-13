class UrlContentFetcher
  def self.fetch(url)
    return nil if url.blank?

    begin
      response = HTTP.timeout(15).get(url)
      return nil unless response.status.success?

      doc = Nokogiri::HTML(response.body.to_s)
      
      # タイトル、メタ説明、本文テキストを抽出
      title = doc.at_css('title')&.text.to_s.strip
      description = doc.at_css('meta[name="description"]')&.[]('content').to_s.strip
      
      # 本文テキストの抽出（最初の5000文字まで）
      body_text = doc.css('p, h1, h2, h3, h4, h5, h6').map(&:text).join(' ').strip[0...5000]
      
      # 結合して返す
      [title, description, body_text].reject(&:empty?).join("\n\n")
    rescue => e
      Rails.logger.error "Failed to fetch URL content: #{e.message}"
      nil
    end
  end
end 