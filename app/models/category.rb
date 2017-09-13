class Category < ActiveRecord::Base
  default_scope { order(:id) }

  def conquerable?(player, game)
    condition = H_CONDITIONS[name]
    return false unless condition
    GameEvaluator.new(game, player).eval(condition)
  end

  H_CONDITIONS = [
    ['文化', "@player.active_colors(@game).size == 5 && @player.boards_for(@game).all? { |b| b.expanded_right? || b.expanded_upward? }"],
    ['技術', nil],
    ['外交', "@player.resource_counts(@game)[Resource.find_by(name: '時間')] >= 12"],
    ['軍事', "values = @player.resource_counts(@game).values; values.size == 6 && values.all? { |v| v >= 3 }"],
    ['科学', "cards = @player.active_cards(@game); cards.size == 5 && cards.all? { |c| c.age.level >= 8 }"],
  ].to_h

  def eql?(other)
    other.is_a?(self.class) && id == other.id
  end

  def hash
    id.hash
  end
end
