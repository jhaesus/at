module At
  module Worker
    class Predictor
      include Worker
      sidekiq_options queue: :low

      def perform timestamp
        database = At::History

        paths = database.keys("history:*").map do |key|
          [key.split(":")[1], JSON.parse(database.get(key)).map { |amount| BigDecimal(amount.to_s) }]
        end.to_h

        match_length_scope = (5..10).to_a.reverse

        diff = BigDecimal("0.001")

        At::Node::Point.as(:to).from(:from, :line).where("to.timestamp = {timestamp}").params(timestamp: timestamp).pluck(:from, :line, :to).map do |previous, line, current|
          match_to_history = paths[current.currency]

          next unless match_to_history

          possibilities = []
          paths.each do |currency, match_from|
            used_possibilities = []
            match_from.each_with_index do |from, from_index|
              guess_index = from_index-1
              next if guess_index==-1
              match_length_scope.each do |match_length|
                next if used_possibilities.include?(guess_index)
                partial = match_from.slice(from_index, match_length)
                next unless partial.length == match_length
                match_to = match_to_history.take(match_length)
                next unless match_to.length == match_length
                if approximate_match(match_to, partial, diff)
                  if next_value = match_from[guess_index]
                    used_possibilities << guess_index

                    At.logger.info "Prognose: #{current.currency} possibility #{currency}[#{guess_index}] => #{next_value} @ #{match_length}"

                    match_length.times do
                      possibilities << next_value
                    end
                  end
                end
              end
            end
          end

          next if possibilities.none?

          rounded = round(possibilities.sum / possibilities.size)

          next if rounded == At.one

          current.prognose.destroy if current.prognose

          At::Node::Prognose.create!(
            point: current,
            last: rounded
          )
        end
      end

      def approximate_match from, to, diff
        from.map { |value| (value - diff)..(value + diff) }.each_with_index.all? { |range, index|
          range.cover?(to[index])
        }
      end
    end
  end
end
