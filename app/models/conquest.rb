class Conquest < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  belongs_to :age
  belongs_to :category

  validates :age_id     , uniqueness: {scope: :game_id}, allow_nil: true
  validates :category_id, uniqueness: {scope: :game_id}, allow_nil: true

  def age?
    type == 'AgeConquest'
  end

  def category?
    type == 'CategoryConquest'
  end
end
