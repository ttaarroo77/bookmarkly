class GenerateTagSuggestionsJob < ApplicationJob
  queue_as :default

  def perform(prompt_id)
    prompt = Prompt.find_by(id: prompt_id)
    return if prompt.nil?

    # URLからコンテンツを取得
    url_content = UrlContentFetcher.fetch(prompt.url)
    return if url_content.blank?

    # AIサービスを使用してタグ候補を生成
    ai_service = AiService.new
    suggestions = ai_service.generate_tag_suggestions(url_content)

    # タグ候補を保存
    suggestions.each do |suggestion|
      prompt.tag_suggestions.create!(
        name: suggestion[:name],
        confidence: suggestion[:confidence]
      )
    end
  rescue => e
    Rails.logger.error "Failed to generate tag suggestions for prompt #{prompt_id}: #{e.message}"
  end
end