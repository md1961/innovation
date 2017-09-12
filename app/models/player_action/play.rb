module PlayerAction

class Play < Base

  def initialize(game, player, card)
    super(game, player)
    @card = card
  end

  def perform
    @player.play(@card, @game)
  end

  def message_after
    "#{@player} played #{@card} from hand"
  end
end

end
