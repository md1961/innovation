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

  def draw_from(stock)
    Player.transaction do
      card = stock.draw
      hand_for(stock.game).add(card)
    end
  end

  def to_s
    name
  end
end
