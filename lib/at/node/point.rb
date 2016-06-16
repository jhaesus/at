module At
  module Node
    class Point
      include Node

      property :currency, type: String
      validates :currency, presence: true
      property :timestamp, type: Integer
      validates :timestamp, presence: true


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

      has_one :out, :to, unique: true, rel_class: "At::Relation::Line", model_class: "At::Node::Point"
      has_one :in, :from, unique: true, rel_class: "At::Relation::Line", model_class: "At::Node::Point"

      def to_line
        rel(dir: :outgoing, type: :line)
      end

      def from_line
        rel(dir: :incoming, type: :line)
      end

      def to_point
        to
      end

      def from_point
        from
      end
    end
  end
end
