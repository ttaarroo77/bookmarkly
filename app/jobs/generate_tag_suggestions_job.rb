class GenerateTagSuggestionsJob < ApplicationJob
  queue_as :default
  
  def perform(prompt_id)
    prompt = Prompt.find_by(id: prompt_id)
    return unless prompt

    begin
      # AIによるタグ提案を生成
      suggested_tags = generate_ai_tags(prompt)
      
      # 提案タグを保存
      if suggested_tags.present?
        suggested_tags.each do |tag_name, count|
          prompt.tag_suggestions.create(name: tag_name.downcase, count: count)
        end
        prompt.update(ai_processing_status: :completed)
      else
        prompt.update(ai_processing_status: :failed)
      end
    rescue => e
      Rails.logger.error "タグ提案生成エラー: #{e.message}"
      prompt.update(ai_processing_status: :failed)
    end
  end

  private

  def generate_ai_tags(prompt)
    # ここにAIによるタグ提案のロジックを実装
    # 例: OpenAI APIを使用してタグを生成する
    
    # 仮実装（実際にはAI APIを使用）
    content = prompt.content.to_s
    title = prompt.title.to_s
    url = prompt.url.to_s
    
    # 簡易的なキーワード抽出（実際の実装ではAI APIを使用）
    text = "#{title} #{content}"
    
    # 一般的なタグの例（実際にはAIが生成）
    common_tags = {
      "AI" => 5,
      "プロンプト" => 4,
      "ChatGPT" => 3,
      "ココナラ" => 3,
      "ライティング" => 2,
      "マーケティング" => 2,
      "SEO" => 1,
      "コピーライティング" => 1
    }
    
    # URLからドメイン名を抽出してタグに追加
    domain_tag = {}
    if url.present?
      begin
        uri = URI.parse(url)
        domain = uri.host.to_s.gsub(/^www\./, '')
        domain_parts = domain.split('.')
        if domain_parts.size >= 2
          service_name = domain_parts[-2]
          domain_tag[service_name] = 4 unless service_name.blank?
        end
      rescue
        # URLのパース失敗時は何もしない
      end
    end
    
    # タグをマージして返す
    common_tags.merge(domain_tag)
  end
end