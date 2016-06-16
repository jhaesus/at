module At
  module Worker
    class History
      include Worker

      cattr_accessor :database do
        Redis.new(At::Settings.history.redis.to_h)
      end

      delegate :database, to: :class

      def perform timestamp
        cmds = {}
        At::Node::Point.as(:to).from(:from, :line).where("to.timestamp = {timestamp}").params(timestamp: timestamp).pluck(:from, :line, :to).map do |previous, line, current|
          key = db_point_key(current)
          next if database.get(key)
          result = []
          rounded = round(line.last)
          result << rounded.to_f if rounded != BigDecimal("1")
          next if result.none?
          if previous_result = database.get((previous_key = db_point_key(previous)))
            cmds[:del] ||= []
            cmds[:del] << [previous_key]
            result += JSON.parse(previous_result)
          end
          cmds[:set] ||= []
          cmds[:set] << [key, result]
        end
        database.pipelined do
          cmds.each do |cmd, args|
            args.each do |arg|
              database.public_send(cmd, *arg)
            end
          end
        end
      end
    end
  end
end
