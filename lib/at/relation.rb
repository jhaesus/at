module At
  module Relation
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload

    included do
      include Neo4j::ActiveRel
    end

    eager_autoload do
      autoload :Line
    end
  end
end
