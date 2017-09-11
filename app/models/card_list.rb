class CardList < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  belongs_to :color
  has_many :card_list_items, -> { order(:ordering) }, dependent: :destroy
  has_many :cards, through: :card_list_items

  def empty?
    cards.empty?
  end

  def add(card)
    ordering = (card_list_items.pluck(:ordering).max&.+ 1) || 0
    card_list_items.create!(card: card, ordering: ordering)
  end

  def unshift(card)
    ordering = (card_list_items.pluck(:ordering).min&.- 1) || 0
    card_list_items.create!(card: card, ordering: ordering)
  end

  def remove(card)
    card_list_items.find_by(card: card).destroy
  end
end
