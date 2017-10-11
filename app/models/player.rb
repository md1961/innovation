class Player < ActiveRecord::Base
  include AiPlayerAttributes

  has_many :playings
  has_many :hands
  has_many :influences
  has_many :boards, -> { order(:color_id) }
  has_many :conquests

  attr_reader :undo_statement, :action_options

  def hand_for(game)
    hands.find_by(game: game)
  end

  def influence_for(game)
    influences.find_by(game: game)
  end

  def boards_for(game)
    boards.where(game: game)
  end

  def active_cards(game)
    boards_for(game).reject(&:empty?).map(&:active_card)
  end

  def active_colors(game)
    active_cards(game).map(&:color)
  end

  def max_age_on_boards(game)
    active_cards(game).map(&:age).map(&:level).max
  end

  def conquests_for(game)
    conquests.where(game: game)
  end

  def cards_in_hand(game)
    hand_for(game).cards
  end

  def resource_counts(game)
    boards_for(game).map(&:resource_counts).inject(Hash.new(0)) { |h_sum, h|
      h_sum.merge(h) { |_, count_sum, count| count_sum + count }
    }
  end

  def influence_point(game)
    influence_for(game).cards.map(&:age).map(&:level).sum
  end

  # TODO: Add method to return params to create *Conquest in Age and Category.
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
