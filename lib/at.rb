module At
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Node
    autoload :Relation
    autoload :Worker
    autoload :History
  end

  def self.env
    ENV["AT_ENV"].inquiry
  end

  def self.profile name
    start = Time.now
    result = yield
    logger.debug "  Profile: #{name} took #{((Time.now.to_f - start.to_f)*1000).to_i}ms"
    result
  end

  def self.debug
    RubyProf.start
    yield
  ensure
    result = RubyProf.stop
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT)
  end

  mattr_accessor :one do
    BigDecimal("1")
  end

  mattr_accessor :session do
    Neo4j::Session.open(:server_db)
  end

  mattr_accessor :logger do
    multi_delegator = Class.new do
      def initialize(*targets)
        @targets = targets
      end

      def self.delegate(*methods)
        methods.each do |m|
          define_method(m) do |*args|
            @targets.map { |t| t.send(m, *args) }
          end
        end
        self
      end

      class <<self
        alias to new
      end
    end

    f = File.open "log/#{At.env}.log", "a"
    f.binmode
    f.sync = false

    logger = ActiveSupport::Logger.new multi_delegator.delegate(:write, :close).to(STDOUT, f)
    logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    logger = ActiveSupport::TaggedLogging.new logger
    logger
  end
end
