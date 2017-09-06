class Board < CardList

  def resource_counts
    return {} if cards.empty?
    cards.last.resources.inject(Hash.new(0)) { |h, r| h[r] += 1; h }
  end
end
