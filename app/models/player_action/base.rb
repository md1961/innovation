module PlayerAction

class Base
  attr_reader :game, :player

  def initialize(game, player)
    @game = game
    @player = player
  end
end

end
