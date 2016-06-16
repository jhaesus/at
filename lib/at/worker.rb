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
      autoload :History
      autoload :Matcher
    end

    def round value
      value.round(3)
    end

    def db_key timestamp, currency
      "history:#{timestamp}-#{currency}"
    end

    def db_point_key point
      db_key(point.timestamp, point.currency)
    end
  end
end
