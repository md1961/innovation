class Card < ActiveRecord::Base
  belongs_to :age
  belongs_to :color
  has_many :effects, class_name: 'CardEffect'
  has_many :card_resources
  has_many :resources, through: :card_resources
end
