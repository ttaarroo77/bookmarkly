class TagSuggester
  # URLからタグを抽出するメソッド
  def self.get_tags_from(url)
    return [] if url.blank?

    # 実際のAI連携やスクレイピングロジックをここに実装
    # 現段階ではダミーデータを返す
    generate_dummy_tags(url)
  end

  private

  # 開発用のダミータグ生成メソッド
  # 本番実装時はAI APIとの連携に置き換える
  def self.generate_dummy_tags(url)
    domain = extract_domain(url)
    
    base_tags = ["web", "bookmark", "reference"]
    
    # URLのドメインに基づいて追加タグを生成
    domain_specific_tags = case domain
    when "github.com"
      ["github", "programming", "code", "repository"]
    when "qiita.com"
      ["qiita", "programming", "tech", "article"]
    when "zenn.dev"
      ["zenn", "programming", "tech", "article"]
    when "youtube.com"
      ["youtube", "video", "tutorial", "entertainment"]
    when "twitter.com", "x.com"
      ["twitter", "social", "news", "discussion"]
    when "medium.com"
      ["medium", "blog", "article", "writing"]
    else
      # ドメイン名から推測されるタグ
      [domain.split('.').first]
    end
    
    # 既存のタグからランダムに選択して追加
    existing_tags = Tag.pluck(:name).sample(3)
    
    # すべてのタグを結合して重複を削除
    (base_tags + domain_specific_tags + existing_tags).uniq.sample(5)
  end
  
  # URLからドメイン部分を抽出するヘルパーメソッド
  def self.extract_domain(url)
    uri = URI.parse(url)
    host = uri.host
    host.start_with?('www.') ? host[4..-1] : host
  rescue URI::InvalidURIError
    ""
  end
end 