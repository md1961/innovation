module PlayerAction

class Play < Base
  attr_reader :card

  def self.add_options_to(chooser)
    game   = chooser.game
    player = chooser.player
    ge = GameEvaluator.new(game, player)

    is_max_age_updatable = ge.max_age_updatable?
    active_colors = player.active_colors(game)

    hand = player.hand_for(game)
    max_age_in_hand = hand.max_age
    hand.cards.each do |card|
      next if ge.decrease_active_card_age?(card)
      pct_weight = 100
      pct_weight *= 2 if is_max_age_updatable && card.age.level == max_age_in_hand
      pct_weight *= 2 unless active_colors.include?(card.color)
      chooser.add(new(game, player, card), pct_weight)
    end
  end

  def initialize(game, player, card)
    super(game, player)
    @card = card
  end

  def perform
    prepare_undo_statement_for_card_move(@card)
    ActiveRecord::Base.transaction do
      @card.card_list(@game).remove(@card)
      @player.boards_for(@game).find_by(color: @card.color).add(@card)
    end
    @card
  end

  def message_after
    "#{@player} played #{@card} from hand"
  end

  def to_s
    "Play#{@card}"
  end
end

end
