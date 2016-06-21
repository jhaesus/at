module At
  module Node
    extend ActiveSupport::Autoload
    extend ActiveSupport::Concern

    included do
      include Neo4j::ActiveNode
    end

    eager_autoload do
      autoload :Point
      autoload :Prognose
    end
  end
end
