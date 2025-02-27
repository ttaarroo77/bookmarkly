class GenerateBookmarkSummaryJob < ApplicationJob
  queue_as :default
  
  def perform(bookmark_id)
    bookmark = Bookmark.find_by(id: bookmark_id)
    return unless bookmark
    
    bookmark.update(ai_processing_status: 'processing')
    summary = AiSummaryService.generate_summary(bookmark.url)
    
    if summary
      bookmark.update(
        description: summary,
        ai_processing_status: 'completed',
        ai_processed_at: Time.current
      )
    else
      bookmark.update(ai_processing_status: 'failed')
    end
  end
end 