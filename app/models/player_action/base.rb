module PlayerAction

class Base
  attr_reader :game, :player, :undo_statement
  attr_accessor :effect_factor

  def initialize(game, player)
    @game = game
    @player = player
  end

  def conquer_category?
    false
  end
end

end
