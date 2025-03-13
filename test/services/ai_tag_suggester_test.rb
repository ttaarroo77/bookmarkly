require 'test_helper'

# データベースに依存しないテスト
class AiTagSuggesterTest < Minitest::Test
  def setup
    # モックユーザーとプロンプトを作成
    @user = mock_user
    @suggester = AiTagSuggester.new(@user)
    @prompt = mock_prompt
  end

  # モックユーザーを作成するヘルパーメソッド
  def mock_user
    user = Object.new
    def user.tags
      []
    end
    user
  end

  # モックプロンプトを作成するヘルパーメソッド
  def mock_prompt
    prompt = Object.new
    def prompt.url
      "https://example.com"
    end
    def prompt.title
      "テストタイトル"
    end
    def prompt.description
      "テスト説明"
    end
    prompt
  end

  def test_mock_tags_returns_expected_format
    mock_tags = @suggester.send(:mock_tags)
    assert_equal Array, mock_tags.class
    assert_equal 3, mock_tags.length
    
    first_tag = mock_tags.first
    assert first_tag.key?("tag")
    assert first_tag.key?("score")
    assert first_tag.key?("is_new")
  end

  def test_suggest_tags_for_prompt_returns_mock_tags_when_MOCK_AI_is_true
    # MOCK_AIを一時的にtrueに設定
    original_mock_ai = ENV['MOCK_AI']
    ENV['MOCK_AI'] = 'true'
    
    begin
      tags = @suggester.suggest_tags_for_prompt(@prompt)
      assert_equal 3, tags.length
      assert_equal "モックタグ1", tags.first["tag"]
    ensure
      # テスト後に元の設定に戻す
      ENV['MOCK_AI'] = original_mock_ai
    end
  end

  def test_parse_tags_from_response_handles_valid_JSON
    # 有効なJSONレスポンスをシミュレート
    response = {
      "choices" => [
        {
          "message" => {
            "content" => "```json\n[{\"tag\":\"テストタグ1\",\"score\":95,\"is_new\":false}]\n```"
          }
        }
      ]
    }
    
    result = @suggester.send(:parse_tags_from_response, response)
    assert_equal 1, result.length
    assert_equal "テストタグ1", result.first["tag"]
  end
end 