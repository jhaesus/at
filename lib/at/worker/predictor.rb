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
          match_to_history = paths[current.currency]

          next unless match_to_history

          possibilities = []
          (4..8).to_a.reverse.each do |match_length|
            match_to = match_to_history.take(match_length)

            paths.each do |currency, match_from|
              match_from.each_with_index do |from, from_index|
                next if (from_index-1==-1)||(from_index==0&&currency==current.currency)
                partial = match_from.slice(from_index, match_length)
                if partial.length == match_length && approximate_match(match_to, partial, BigDecimal("0.001"))
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

      def approximate_match from, to, diff
        one = BigDecimal("1")
        from.map { |value|
          if value > one
            [value - diff, one].max..(value + diff)
          else
            (value - diff)..[value + diff, one].min
          end
        }.each_with_index.all? { |range, index|
          range.cover?(to[index])
        }
      end
    end
  end
end
