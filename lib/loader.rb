module Loader
  class << self
    def require matcher
      action matcher, :require
    end

    def load matcher
      action matcher, :load
    end

    protected

    def list matcher
      Dir[matcher].map do |relative|
        Pathname.new(relative).expand_path
      end
    end

    def action matcher, action
      list(matcher).map(&Kernel.method(action))
    end
  end
end
