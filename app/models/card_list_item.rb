class CardListItem < ActiveRecord::Base
  belongs_to :card_list
  belongs_to :card

  after_destroy :unexpand_board

  private

    def unexpand_board
      card_list.not_expanded! if card_list.is_a?(Board) && card_list.cards.size < 2
    end
end
