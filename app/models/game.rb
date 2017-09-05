class Game < ActiveRecord::Base
  has_many :playings
  has_many :players, through: :playings
end
