class Age < ActiveRecord::Base

  def conquerable?(player, game)
    return false if game.conquered?(self)
    player.influence_point(game) >= level * 5 \
      && player.max_age_on_boards(game) >= level
  end

  def next
    Age.find_by(level: level + 1)
  end

  def eql?(other)
    other.is_a?(self.class) && id == other.id
  end

  def hash
    id.hash
  end

  def to_s
    "#{level} #{name}"
  end
end
