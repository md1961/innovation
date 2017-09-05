class CardList < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  belongs_to :age
  belongs_to :color
  has_many :card_list_items, -> { order(:ordering) }
  has_many :cards, through: :card_list_items
end
