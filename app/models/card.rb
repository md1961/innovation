class Card < ActiveRecord::Base
  belongs_to :age
  belongs_to :color
  has_many :effects, -> { order(:id) }, class_name: 'CardEffect'
  has_many :card_resources
  has_many :resources, through: :card_resources
  has_many :card_list_items
  has_many :card_lists, through: :card_list_items

  POS_LT = 'LT'
  POS_LB = 'LB'
  POS_CB = 'CB'
  POS_RB = 'RB'

  POSITIONS = [POS_LT, POS_LB, POS_CB, POS_RB]
  POSITIONS_AT_BOTTOM = POSITIONS[1, 3]

  LEFT   = [POS_LT, POS_LB]
  RIGHT  = [POS_RB]
  BOTTOM = POSITIONS_AT_BOTTOM

  def resource_at(position_abbr)
    card_resources.joins(:position).where('resource_positions.abbr = ?', position_abbr).first&.resource
  end

  def resources_at(card_side_for_position_abbrs)
    return [] unless card_side_for_position_abbrs
    card_side_for_position_abbrs.map { |pos| resource_at(pos) }.compact
  end

  def card_list(game)
    card_lists.find_by(game: game)
  end

  def prev
    self.class.where('id < ?', id).order(id: :desc).first || self
  end

  def next
    self.class.where('id > ?', id).order(id: :asc ).first || self
  end

  def forcing?
    (effects.size == 1 && !effects.first.is_for_all) \
      || (effects.size == 2 && !effects.first.is_for_all && effects.last.conditional_on_effect_above?)
  end

  def reuse(game)
    stock = game.stocks.find_by(age: age)
    self.class.transaction do
      card_list(game).remove(self)
      stock.add(self)
    end
  end

  def offer(game)
    self.class.transaction do
      card_list(game).remove(self)
      game.current_player.hand_for(game).add(self)
    end
  end

  def to_s
    "[#{age.level}]#{title}"
  end
end
