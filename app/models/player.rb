class Player < ActiveRecord::Base
  has_many :playings
  has_many :hands
  has_many :influences
  has_many :boards, -> { order(:color_id) }

  def hand_for(game)
    hands.find_by(game: game)
  end

  def influence_for(game)
    influences.find_by(game: game)
  end

  def boards_for(game)
    boards.where(game: game)
  end

  def cards_in_hand(game)
    hand_for(game).cards.sort_by { |card| [card.age_id, card.color_id] }
  end

  def resource_counts
    boards.map(&:resource_counts).inject { |h_sum, h|
      h_sum.merge(h) { |_, count_sum, count| count_sum + count }
    }
  end

  def influence_point(game)
    influence_for(game).cards.map(&:age).map(&:level).sum
  end

  def draw_from(stock)
    self.class.transaction do
      card = stock.draw
      hand_for(stock.game).add(card)
    end
  end

  def play(card, game)
    self.class.transaction do
      hand_for(game).card_list_items.find_by(card: card).destroy
      boards_for(game).find_by(color: card.color).add(card)
    end
  end

  def score(card, game)
    self.class.transaction do
      hand_for(game).card_list_items.find_by(card: card).destroy
      influence_for(game).add(card)
    end
  end

  def store(card, game)
    self.class.transaction do
      hand_for(game).card_list_items.find_by(card: card).destroy
      boards_for(game).find_by(color: card.color).unshift(card)
    end
  end

  def to_s
    name
  end
end
