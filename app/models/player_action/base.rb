module PlayerAction

class Base
  attr_reader :game, :player, :undo_statement

  def initialize(game, player)
    @game = game
    @player = player
  end

  def conquer_category?
    false
  end

  def effect_factor
    nil
  end
end

end
