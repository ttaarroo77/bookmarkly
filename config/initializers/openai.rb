OpenAI.configure do |config|
  config.access_token = if ENV["MOCK_AI"] == "true"
    "dummy_key_for_mock_mode"
  else
    ENV.fetch("OPENAI_API_KEY") do
      if Rails.env.development? || Rails.env.test?
        Rails.logger.warn "WARNING: OPENAI_API_KEY not set. Using dummy key for development."
        "dummy_key_for_development"
      else
        raise "Missing OPENAI_API_KEY environment variable"
      end
    end
  end
end