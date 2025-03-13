class GenerateTagSuggestionsJob < ApplicationJob
  queue_as :default
  
  retry_on StandardError, attempts: 3, wait: 5.seconds

  def perform(prompt_id)
    prompt = Prompt.find_by(id: prompt_id)
    return unless prompt

    begin
      # AIサービスを使用してタグ候補を生成
      tags = AiService.generate_tag_suggestions(prompt)
      Rails.logger.info "Generated #{tags.size} tag suggestions for prompt #{prompt_id}"
    rescue => e
      Rails.logger.error "Failed to generate tag suggestions: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end
  end
end