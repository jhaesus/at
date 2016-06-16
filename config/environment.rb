ENV["AT_ENV"] ||= "development"
ENV['TZ'] = 'UTC'

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__)
require "bundler/setup"
Bundler.require(:default, ENV["AT_ENV"].to_sym)
