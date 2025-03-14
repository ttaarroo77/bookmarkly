# config/environments/test.rb - テスト環境の設定


require "active_support/core_ext/integer/time"

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Deviseのテスト設定
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # ログレベルを詳細に設定
  config.log_level = :debug

  # Turn false under Spring and add config.action_view.cache_template_loading = true.
  config.cache_classes = false  # テスト中にクラスをリロードできるように変更

  # Eager loading loads your whole application. When running a single test locally,
  # this probably isn't necessary. It's a good idea to do in a CI environment or if
  # you're using tools that preload the whole Rails environment.
  config.eager_load = false  # テスト中は必要に応じてロードするように変更

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false  # 例外を表示するように変更

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true
  
  # Deviseのテスト用設定
  config.middleware.use Warden::Manager do |manager|
    manager.default_strategies(scope: :user).unshift :database_authenticatable
    manager.failure_app = Devise::FailureApp
  end
  
  # Deviseのテスト用設定を追加
  config.after_initialize do
    Devise.setup do |devise_config|
      # テスト環境ではパラノイドモードを無効化
      devise_config.paranoid = false
      # テスト環境では認証キーを大文字小文字区別なしに
      devise_config.case_insensitive_keys = [:email]
      # テスト環境ではストレッチ回数を最小に
      devise_config.stretches = 1
    end
  end
end
