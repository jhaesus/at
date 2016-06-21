module At
  module Worker
    class Predictor
      include Worker

      def perform timestamp
        database = At::History

        paths = database.keys("history:*").map do |key|
          [key.split(":")[1], JSON.parse(database.get(key)).map { |amount| BigDecimal(amount.to_s) }]
        end.to_h

        At::Node::Point.as(:to).from(:from, :line).where("to.timestamp = {timestamp}").params(timestamp: timestamp).pluck(:from, :line, :to).map do |previous, line, current|
          possibilities = []
          (5..10).to_a.reverse.each do |match_length|
            match_to = paths[current.currency].take(match_length)

            paths.each do |currency, match_from|
              match_from.each_with_index do |from, from_index|
                next if (from_index-1==-1)||(from_index==0&&currency==current.currency)
                partial = match_from.slice(from_index, match_length)
                if partial.length == match_length && partial == match_to
                  next_value = match_from[from_index-1]
                  match_length.times do
                    possibilities << next_value
                  end if next_value
                end
              end
            end
          end

          next if possibilities.none?

          rounded = (possibilities.sum / possibilities.size).round(3)

          next if rounded == BigDecimal("1")

          current.prognose.destroy if current.prognose

          At::Node::Prognose.create!(
            point: current,
            last: rounded
          )
        end
      end
    end
  end
end
