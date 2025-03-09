class GeneratePromptSummaryJob < ApplicationJob
  queue_as :default
  
  def perform(prompt_id)
    prompt = Prompt.find_by(id: prompt_id)
    return unless prompt
    
    prompt.update(ai_processing_status: 'processing')
    summary = AiSummaryService.generate_summary(prompt.url)
    
    if summary
      prompt.update(
        description: summary,
        ai_processing_status: 'completed',
        ai_processed_at: Time.current
      )
    else
      prompt.update(ai_processing_status: 'failed')
    end
  end
end 