class Board < CardList
  belongs_to :player

  enum expansion: {not_expanded: 0, expanded_left: 1, expanded_right: 2, expanded_upward: 3}

  after_save :unexpand

  def active_card
    cards.last
  end

  def resource_counts
    return {} if cards.empty?

    card_side = \
      if expanded_left?
        Card::RIGHT
      elsif expanded_right?
        Card::LEFT
      elsif expanded_upward?
        Card::BOTTOM
      else
        nil
      end
    resources_expanded = cards[0 .. -2].flat_map { |card| card.resources_at(card_side) }

    (cards.last.resources + resources_expanded).inject(Hash.new(0)) { |h, r| h[r] += 1; h }
  end

  private

    def unexpand
      self.expansion = 0 if cards.size < 2
    end
end
