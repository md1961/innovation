class CardResource < ActiveRecord::Base
  belongs_to :card
  belongs_to :resource
  belongs_to :resource_position
end
