# Sidekiq設定ファイル

# Herokuの環境変数からRedis URLを取得
redis_url = ENV['REDIS_URL'] || 'redis://localhost:6379/0'

# SSL証明書の検証をスキップするオプションを追加
redis_conn = { url: redis_url }
if redis_url.start_with?('rediss://')
  redis_conn[:ssl_params] = { verify_mode: OpenSSL::SSL::VERIFY_NONE }
end

Sidekiq.configure_server do |config|
  config.redis = redis_conn
end

Sidekiq.configure_client do |config|
  config.redis = redis_conn
end