module PlayerAction

class Play < Base

  def initialize(game, player, card)
    super(game, player)
    @card = card
  end

  def perform
    prepare_undo_statement
    @player.play(@card, @game)
  end

  def message_after
    "#{@player} played #{@card} from hand"
  end

  private

    # TODO: Move prepare_undo_statement() to Player.
    def prepare_undo_statement
      params_undo = @card.card_list(@game).card_list_items.find_by(card: @card)
                      .attributes.reject { |k, _v| k == 'id' }
      @undo_statement = <<~END
        card = Card.find_by(#{@card.id});
        card.card_list(Game.find_by(#{@game.id})).remove(card);
        CardListItem.create!(#{params_undo})
      END
    end
end

end
