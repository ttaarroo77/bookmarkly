class DescriptionGenerator
  # URLから説明文を生成するメソッド
  def self.generate_from_url(url, title = nil)
    return "" if url.blank?

    # 実際のAI連携やスクレイピングロジックをここに実装
    # 現段階ではダミーデータを返す
    generate_dummy_description(url, title)
  end

  private

  # 開発用のダミー説明文生成メソッド
  # 本番実装時はAI APIとの連携に置き換える
  def self.generate_dummy_description(url, title)
    domain = extract_domain(url)
    
    base_description = "このブックマークは#{domain}からの情報です。"
    
    title_part = title.present? ? "「#{title}」というタイトルの" : ""
    
    domain_specific_part = case domain
    when "github.com"
      "GitHubリポジトリの#{title_part}コードやプロジェクト情報が含まれています。開発やプログラミングの参考になるでしょう。"
    when "qiita.com"
      "Qiitaの#{title_part}技術記事です。プログラミングや開発に関する知識が含まれています。"
    when "zenn.dev"
      "Zennの#{title_part}技術記事です。最新のプログラミングトレンドや開発テクニックが解説されています。"
    when "youtube.com"
      "YouTubeの#{title_part}動画コンテンツです。視覚的な解説や情報が含まれています。"
    when "twitter.com", "x.com"
      "Twitterの#{title_part}投稿です。最新の情報や議論が含まれている可能性があります。"
    when "medium.com"
      "Mediumの#{title_part}記事です。詳細な解説や個人の見解が含まれています。"
    else
      "#{domain}の#{title_part}Webページです。参考情報として保存されています。"
    end
    
    "#{base_description} #{domain_specific_part}\n\n後で確認するために保存しました。"
  end
  
  # URLからドメイン部分を抽出するヘルパーメソッド
  def self.extract_domain(url)
    uri = URI.parse(url)
    host = uri.host
    host.start_with?('www.') ? host[4..-1] : host
  rescue URI::InvalidURIError
    "不明なドメイン"
  end
end 