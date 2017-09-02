class CardResource < ActiveRecord::Base
  belongs_to :card
  belongs_to :resource
  belongs_to :position, class_name: 'ResourcePosition', foreign_key: 'resource_position_id'
end
