module At
  module Worker
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload

    included do
      include Sidekiq::Worker
      sidekiq_options backtrace: true

      # @queue ||= :default
    end

    eager_autoload do
      autoload :Ticker
      autoload :Archiver
      autoload :Predictor
    end

    def round value
      value.round(3)
    end
  end
end
