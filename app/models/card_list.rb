class CardList < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  belongs_to :age
  belongs_to :color
end
