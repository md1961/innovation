module PlayerAction

class Store < Base

  def initialize(game, player, card)
    super(game, player)
    @card = card
  end

  def perform
    prepare_undo_statement_for_card_move(@card)
    ActiveRecord::Base.transaction do
      @card.card_list(@game).remove(@card)
      @player.boards_for(@game).find_by(color: @card.color).unshift(@card)
    end
    @card
  end

  def to_s
    "Store#{@card}"
  end
end

end
