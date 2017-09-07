class Board < CardList
  enum expansion: {not_expanded: 0, expanded_left: 1, expanded_right: 2, expanded_upward: 3}

  def resource_counts
    return {} if cards.empty?
    cards.last.resources.inject(Hash.new(0)) { |h, r| h[r] += 1; h }
  end
end
