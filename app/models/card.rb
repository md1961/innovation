class Card < ActiveRecord::Base
  belongs_to :age
  belongs_to :color
  has_many :effects, class_name: 'CardEffect'
  has_many :card_resources
  has_many :resources, through: :card_resources

  POS_LT = 'LT'
  POS_LB = 'LB'
  POS_CB = 'CB'
  POS_RB = 'RB'

  POSITIONS = [POS_LT, POS_LB, POS_CB, POS_RB]

  def resource_at(position_abbr)
    card_resources.joins(:position).where('resource_positions.abbr = ?', position_abbr).first&.resource
  end
end
