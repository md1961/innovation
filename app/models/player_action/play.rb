module PlayerAction

class Play < Base

  def self.add_options_to(chooser)
    game   = chooser.game
    player = chooser.player
    ge = GameEvaluator.new(game, player)

    is_max_age_updatable = ge.max_age_updatable?
    hand = player.hand_for(game)
    max_age_in_hand = hand.max_age
    hand.cards.each do |card|
      pct_weight = is_max_age_updatable && card.age.level == max_age_in_hand ? 200 : 100
      chooser.add(new(game, player, card), pct_weight)
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
