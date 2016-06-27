module At
  module Worker
    class Archiver
      include Worker

      def perform timestamp, predict=true
        database = At::History
        sets = []
        At::Node::Point.as(:to).from(:from, :line).where("to.timestamp = {timestamp}").params(timestamp: timestamp).pluck(:from, :line, :to).map do |previous, line, current|
          key = db_key(current.currency)
          result = []
          rounded = round(line.last)
          result << rounded.to_f if rounded != BigDecimal("1")
          if previous_result = database.get(key)
            result += JSON.parse(previous_result)
          end
          next if result.none?
          sets << [key, minimize(result)]
        end
        database.pipelined do
          sets.each do |args|
            database.public_send(:set, *args)
          end
        end

        At::Worker::Predictor.perform_in 10.seconds, timestamp if predict
      end

      def minimize arr, max_length=10
        (2..[max_length, arr.length].min).inject(arr) { |memo, i| compact(memo, i) }
      end

      def compact arr, length
        slices = arr.each_slice(length).each_with_index
        slices.map { |item, index|
          slices.to_a.slice(index+1).try(:[], 0) == item ? nil : item
        }.compact.flatten
      end

      def self.db_key currency
        "history:#{currency}"
      end

      delegate :db_key, to: :class
    end
  end
end
