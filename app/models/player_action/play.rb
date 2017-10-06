module PlayerAction

class Play < Base
  attr_reader :card

  def self.add_options_to(chooser)
    game   = chooser.game
    player = chooser.player
    ge = GameEvaluator.new(game, player)

    is_max_age_updatable = ge.max_age_updatable?
    hand = player.hand_for(game)
    max_age_in_hand = hand.max_age
    hand.cards.each do |card|
      next if ge.decrease_active_card_age?(card)
      pct_weight = is_max_age_updatable && card.age.level == max_age_in_hand ? 200 : 100
      chooser.add(new(game, player, card), pct_weight)
    end
  end

  def initialize(game, player, card)
    super(game, player)
    @card = card
  end

  def perform
    prepare_undo_statement_for_play(@card, @game)
    ActiveRecord::Base.transaction do
      @card.card_list(@game).remove(@card)
      @player.boards_for(@game).find_by(color: @card.color).add(@card)
    end
  end

  def message_after
    "#{@player} played #{@card} from hand"
  end

  def to_s
    "Play#{@card}"
  end

  private

    def prepare_undo_statement_for_play(card, game)
      params_undo = card.card_list(game).card_list_items.find_by(card: card)
                      .attributes.reject { |k, _v| k == 'id' }
      @undo_statement = <<~END
        card = Card.find(#{card.id});
        card.card_list(Game.find_by(#{game.id})).remove(card);
        CardListItem.create!(#{params_undo})
      END
    end
end

end
