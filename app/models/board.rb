class Board < CardList
  belongs_to :player

  enum expansion: {not_expanded: 0, expanded_left: 1, expanded_right: 2, expanded_upward: 3}

  attr_accessor :shows_info

  def expanded?
    !not_expanded?
  end

  def expandable_left?
    cards.size >= 2 && not_expanded?
  end

  def expandable_right?
    cards.size >= 2 && (not_expanded? || expanded_left?)
  end

  def expandable_upward?
    cards.size >= 2 && !expanded_upward?
  end

  def active_card
    cards.last
  end

  def active_card_decreasing_age?
    cards.size >= 2 && cards[-2].age.level > active_card.age.level
  end

  def resource_counts
    return {} if empty?

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
end
