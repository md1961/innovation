module PlayerAction

class Reuse < Base

  def initialize(game, player, card)
    super(game, player)
    @card = card
  end

  def perform
    prepare_undo_statement_for_card_move(@card)
    stock = @game.stocks.find_by(age: @card.age)
    ActiveRecord::Base.transaction do
      @card.card_list(@game).remove(@card)
      stock.add(@card)
    end
  end
end

end
