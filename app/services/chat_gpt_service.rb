class ChatGptService
  require "openai"

  def initialize
    @client = OpenAI::Client.new
    Rails.logger.debug "ChatGPTService initialized with API key: #{ENV['OPENAI_API_KEY']&.slice(0,7)}..."
  end

  def chat(prompt)
    return mock_response(prompt) if ENV["MOCK_AI"] == "true"

    Rails.logger.debug "Sending request to OpenAI API..."
    response = @client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: "You are a helpful assistant. response to japanese" },
          { role: "user", content: prompt }
        ],
        temperature: 0.7,
        max_tokens: 200
      }
    )
    Rails.logger.debug "Response received from OpenAI API"
    response.dig("choices", 0, "message", "content")
  rescue => e
    Rails.logger.error "ChatGPT API Error: #{e.message}"
    Rails.logger.error "Current API key prefix: #{ENV['OPENAI_API_KEY']&.slice(0,7)}"
    Rails.logger.error e.backtrace.join("\n")
    "申し訳ありません。エラーが発生しました。"
  end

  private

  def mock_response(prompt)
    "【モックモード】「#{prompt}」に対する応答です。"
  end
end 