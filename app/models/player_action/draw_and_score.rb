module PlayerAction

class DrawAndScore < Base

  def initialize(game, player, age)
    super(game, player)
    @age = age
  end

  def perform
    draw = Draw.new(game, player, age)
    card = draw.perform
    score = Score.new(game, player, card)
    score.perform
  end
end

end
