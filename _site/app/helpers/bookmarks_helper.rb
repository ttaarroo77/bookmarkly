module BookmarksHelper
  def format_tags(tags)
    return "" if tags.blank?
    
    if tags.is_a?(Array)
      tags.join(", ")
    elsif tags.is_a?(String) && tags.start_with?("[") && tags.end_with?("]")
      # JSONのような形式の文字列から配列に変換して結合
      begin
        JSON.parse(tags).join(", ")
      rescue
        # パースに失敗した場合はそのまま返す
        tags
      end
    else
      tags.to_s
    end
  end
end
