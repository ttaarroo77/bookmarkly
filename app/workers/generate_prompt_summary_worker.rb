class GeneratePromptSummaryWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(prompt_id)
    prompt = Prompt.find_by(id: prompt_id)
    return unless prompt

    prompt.update(ai_processing_status: :processing)
    
    begin
      # AIによる概要生成処理
      # ここに実際の処理を記述
      
      # 成功した場合
      prompt.update(
        description: "AIによって生成された概要がここに入ります", 
        ai_processing_status: :completed,
        ai_processed_at: Time.current
      )
    rescue => e
      # エラーが発生した場合
      Rails.logger.error "AI概要生成エラー: #{e.message}"
      prompt.update(ai_processing_status: :failed)
    end
  end
end 