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

  protected

    def prepare_undo_statement_for_card_move(card)
      params_undo = card.card_list(@game).card_list_items.find_by(card: card)
                      .attributes.reject { |k, _v| k == 'id' }
      @undo_statement = <<~END
        card = Card.find(#{card.id});
        card.card_list(Game.find(#{@game.id})).remove(card);
        CardListItem.create!(#{params_undo})
      END
    end
end

end
