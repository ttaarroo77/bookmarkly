# 環境変数管理用（最上部に配置）
gem 'dotenv-rails', groups: [:development, :test]

ruby "3.2.2"  # または最新の安定版
source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.1"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Add devise for authentication
gem "devise"

# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 2.5.0"

# OpenAI API
gem 'ruby-openai'

# 非同期処理
gem 'sidekiq'
gem 'redis', '~> 5.0'  # Sidekiqに必要なRedis

# HTTP通信
gem 'faraday'

# HTMLパース
gem 'nokogiri'

# HTTP通信用
gem 'httparty'

# HTTP通信用（より高機能なクライアント）
gem 'http'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # テスト用のgem
  gem 'rspec-rails', '~> 7.1'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'shoulda-matchers'
  # gem 'database_cleaner-active_record'  # コメントアウトまたは削除
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
