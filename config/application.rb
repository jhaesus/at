require_relative "environment"

$LOAD_PATH.unshift(Pathname.new("lib").expand_path.to_s)
ActiveSupport::Dependencies.mechanism = :require
ActiveSupport::Dependencies.autoload_paths << "lib"

At::Settings.instance = At::Settings.new(YAML.load(File.open("config/settings.yml"))[ENV["AT_ENV"]])
Loader.require "config/environments/#{ENV["AT_ENV"]}.rb"
Loader.require "config/initializers/**/*.rb"
