class Card < ActiveRecord::Base
  belongs_to :age
  belongs_to :color
end
