class GenerateDescriptionJob < ApplicationJob
  queue_as :default

  def perform(prompt_id)
    prompt = Prompt.find_by(id: prompt_id)
    return if prompt.nil?

    # 処理中に状態を更新
    prompt.update(ai_processing_status: :processing) if prompt.respond_to?(:ai_processing_status)

    # URLからコンテンツを取得
    url_content = UrlContentFetcher.fetch(prompt.url)
    return if url_content.blank?

    # AIサービスを使用して説明文を生成
    ai_service = AiService.new
    description = ai_service.generate_description(url_content)

    # 説明文を保存
    prompt.update(
      description: description,
      ai_processing_status: :completed,
      ai_processed_at: Time.current
    )
  rescue => e
    Rails.logger.error "Failed to generate description for prompt #{prompt_id}: #{e.message}"
    prompt.update(ai_processing_status: :failed) if prompt.respond_to?(:ai_processing_status)
  end
end