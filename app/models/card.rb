class Card < ActiveRecord::Base
  belongs_to :age
  belongs_to :color
  has_many :effects, class_name: 'CardEffect'
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

  def resource_at(position_abbr)
    card_resources.joins(:position).where('resource_positions.abbr = ?', position_abbr).first&.resource
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
end
