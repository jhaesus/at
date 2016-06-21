module At
  module Node
    class Prognose
      include Node

      property :last, type: BigDecimal
      validates :last, presence: true

      has_one :in, :point, unique: true, model_class: "At::Node::Point", type: :guess
    end
  end
end
