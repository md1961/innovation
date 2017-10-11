module PlayerAction

class Score < Base

  def initialize(game, player, card)
    super(game, player)
    @card = card
  end

  def perform
    prepare_undo_statement_for_card_move(@card)
    ActiveRecord::Base.transaction do
      @card.card_list(@game).remove(@card)
      @player.influence_for(@game).add(@card)
    end
  end
end

end
