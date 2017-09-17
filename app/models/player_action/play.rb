module PlayerAction

class Play < Base

  def self.add_options_to(chooser)
    game   = chooser.game
    player = chooser.player
    player.hand_for(game).cards.each do |card|
      chooser.add(new(game, player, card))
    end
  end

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
