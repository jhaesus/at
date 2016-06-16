Sidekiq.configure_server do |config|
  require "resolv-replace"
  config.redis = At::Settings.sidekiq.redis.to_h
  At::Worker.eager_load!
end
