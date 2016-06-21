module At
  module Worker
    class Ticker
      include Worker
      include Sidetiq::Schedulable
      recurrence do
        hourly.minute_of_hour(0, 15, 30, 45)
      end

      def perform
        time = Time.now
        minute = [0, 15, 30, 45, 60].sort_by { |value| (value - time.min).abs }.first % 60
        current_time_key = Time.new(time.year, time.month, time.day, time.hour, minute).to_i
        # puts [time.year, time.month, time.day, time.hour, [{time.min => minute}]].inspect
        summaries = Bittrex::MarketSummary.all
        markets = Bittrex::Market.all

        markets.select(&:active).select { |market| market.base == "BTC" }.each do |market|
          summary = summaries.detect { |summary| summary.name == market.name }

          point = At::Node::Point.create!(
            currency: market.currency,
            high: summary.high,
            last: summary.last,
            low: summary.low,
            bid: summary.bid,
            ask: summary.ask,
            timestamp: current_time_key
          )

          if previous = At::Node::Point.as(:p).where("p.currency = {currency} AND p.timestamp < {timestamp}").
            params(currency: market.currency, timestamp: current_time_key).
            order(timestamp: :desc).pluck(:p).first
            At::Relation::Line.create!(
              from_node: previous,
              to_node: point,
              high: point.high / previous.high,
              last: point.last / previous.last,
              low: point.low / previous.low,
              bid: point.bid / previous.bid,
              ask: point.ask / previous.ask
            )
          end
        end

        At::Worker::Archiver.perform_in 10.seconds, current_time_key
      end
    end
  end
end
