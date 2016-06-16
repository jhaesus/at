module At
  module Relation
    class Line
      include Relation
      from_class "At::Node::Point"
      to_class "At::Node::Point"
      type :line

      property :high, type: BigDecimal
      validates :high, presence: true
      property :low, type: BigDecimal
      validates :low, presence: true
      property :last, type: BigDecimal
      validates :last, presence: true
      property :bid, type: BigDecimal
      validates :bid, presence: true
      property :ask, type: BigDecimal
      validates :ask, presence: true

      def from_point
        from_node
      end

      def to_point
        to_node
      end

      def from_line
        from_node.from_line
      end

      def to_line
        to_node.to_line
      end
    end
  end
end
