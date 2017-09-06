class Player < ActiveRecord::Base
  has_many :playings
  has_many :hands
  has_many :boards, -> { order(:color_id) }

  def hand_for(game)
    hands.find_by(game: game)
  end

  def boards_for(game)
    boards.where(game: game)
  end

  def cards_in_hand(game)
    hand_for(game).cards.sort_by { |card| [card.age_id, card.color_id] }
  end

  def draw_from(stock)
    Player.transaction do
      card = stock.draw
      hand_for(stock.game).add(card)
    end
  end

  def play(card, game)
    Player.transaction do
      hand_for(game).card_list_items.find_by(card: card).destroy
      boards_for(game).find_by(color: card.color).add(card)
    end
  end

  def to_s
    name
  end
end
