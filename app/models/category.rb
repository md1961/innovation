class Category < ActiveRecord::Base
  default_scope { order(:id) }

  def conquerable?(player, game)
    return false if game.conquered?(self)
    condition = H_CONDITIONS[name]
    return false unless condition
    GameEvaluator.new(game, player).eval(condition)
  end

  H_CONDITIONS = [
    ['文化', "AC_COLORS.size == 5 && BOARDS.all? { |b| b.expanded_right? || b.expanded_upward? }"],
    ['技術', nil],
    ['外交', "RES_COUNTS[Resource.time] >= 12"],
    ['軍事', "values = RES_COUNTS.values; values.size == 6 && values.all? { |v| v >= 3 }"],
    ['科学', "cards = AC_CARDS; cards.size == 5 && cards.all? { |c| c.age.level >= 8 }"],
  ].to_h

  def eql?(other)
    other.is_a?(self.class) && id == other.id
  end

  def hash
    id.hash
  end

  def to_s
    name
  end
end
