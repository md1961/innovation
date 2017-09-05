class Game < ActiveRecord::Base
  has_many :playings
  has_many :players, through: :playings
  has_many :stocks, -> { order(:age_id) }
  belongs_to :current_player, class_name: 'Player', foreign_key: :current_player_id

  after_create :prepare

  private

    def prepare
      Age.order(:level).each do |age|
        stocks.create!(age: age)
      end
    end
end
