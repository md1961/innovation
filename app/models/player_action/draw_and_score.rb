module PlayerAction

class DrawAndScore < Base

  def initialize(game, player, age)
    super(game, player)
    @age = age
    @draw = Draw.new(game, player, age)
  end

  def perform
    card = @draw.perform
    score = Score.new(game, player, card)
    score.perform
  end

  def to_s
    "#{@draw}&Score"
  end
end

end
