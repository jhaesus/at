require_relative "config/application"
require "sidekiq/web"
run Sidekiq::Web
