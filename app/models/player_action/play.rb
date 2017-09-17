module PlayerAction

class Play < Base

  def initialize(game, player, card)
    super(game, player)
    @card = card
  end

  def perform
    @player.play(@card, @game)
    @undo_statement = @player.undo_statement
  end

  def message_after
    "#{@player} played #{@card} from hand"
  end
end

end
