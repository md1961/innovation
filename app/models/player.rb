class Player < ActiveRecord::Base
  include AiPlayerAttributes

  has_many :playings
  has_many :hands
  has_many :influences
  has_many :boards, -> { order(:color_id) }
  has_many :conquests

  def hand_for(game)
    hands.find_by(game: game)
  end

  def influence_for(game)
    influences.find_by(game: game)
  end

  def boards_for(game)
    boards.where(game: game)
  end

  def max_age_on_boards(game)
    boards_for(game).reject(&:empty?).map(&:active_card).map(&:age).map(&:level).max
  end

  def conquests_for(game)
    conquests.where(game: game)
  end

  def cards_in_hand(game)
    hand_for(game).cards
  end

  def resource_counts(game)
    boards_for(game).map(&:resource_counts).inject { |h_sum, h|
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
      card.card_list(game).card_list_items.find_by(card: card).destroy
      influence_for(game).add(card)
    end
  end

  def store(card, game)
    self.class.transaction do
      card.card_list(game).card_list_items.find_by(card: card).destroy
      boards_for(game).find_by(color: card.color).unshift(card)
    end
  end

  def conquer(target, game)
    type = "#{target.class}Conquest"
    type_attr = :"#{target.class.name.downcase}"
    conquests_for(game).create!(type: type, type_attr => target)
  end

  def eql?(other)
    other.is_a?(self.class) && id == other.id
  end

  def hash
    id.hash
  end

  def to_s
    name
  end
end
