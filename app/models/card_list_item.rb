class CardListItem < ActiveRecord::Base
  belongs_to :card_list
  belongs_to :card
end
