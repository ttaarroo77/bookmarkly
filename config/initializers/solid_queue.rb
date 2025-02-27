Rails.application.config.solid_queue.connects_to = {
  database: { writing: :primary, reading: :primary }
}

Rails.application.config.solid_queue.concurrency = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
Rails.application.config.solid_queue.dispatch_interval = 1