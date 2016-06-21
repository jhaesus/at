Sidekiq.configure_server do |config|
  config.redis = At::Settings.sidekiq.redis.to_h
  At::Worker.eager_load!
end

Sidekiq.configure_client do |config|
  config.redis = At::Settings.sidekiq.redis.to_h
end
