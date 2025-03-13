class AiTagSuggester
  require 'openai'
  require 'httparty'
  require 'nokogiri'

  def initialize(user)
    @user = user
    @ai_service = AiService.new
  end

  # URLからタグを提案
  def suggest_tags_for_url(url)
    return [] if url.blank?

    begin
      content = UrlContentFetcher.fetch(url)
      return [] if content.blank?

      @ai_service.generate_tag_suggestions(content)
    rescue => e
      Rails.logger.error "Failed to suggest tags: #{e.message}"
      []
    end
  end
end