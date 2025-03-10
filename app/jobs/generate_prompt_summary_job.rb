class GeneratePromptSummaryJob < ApplicationJob
  queue_as :default

  def perform(prompt_id)
    prompt = Prompt.find_by(id: prompt_id)
    return unless prompt

    begin
      prompt.update(ai_processing_status: :processing)
      
      # AIによる概要生成処理
      # 実際の処理をここに記述
      
      prompt.update(
        description: "このプロンプトの説明文はAIによって生成されます。",
        ai_processing_status: :completed,
        ai_processed_at: Time.current
      )
    rescue => e
      Rails.logger.error "AI概要生成エラー: #{e.message}"
      prompt.update(ai_processing_status: :failed)
    end
  end
end 