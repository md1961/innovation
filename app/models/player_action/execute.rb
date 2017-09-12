module PlayerAction

class Execute < Base

  def initialize(game, player, board)
    super(game, player)
    @board = board
  end

  def perform
  end

  def message_after
    "#{@player} wants to execute #{@board.active_card}"
  end
end

end
