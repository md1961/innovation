class Game < ActiveRecord::Base
  has_many :playings, -> { order(:ordering) }, dependent: :destroy
  has_many :players, through: :playings
  has_many :stocks, -> { order(:age_id) }, dependent: :destroy
  has_many :hands, dependent: :destroy
  belongs_to :current_player, class_name: 'Player', foreign_key: :current_player_id

  after_create :prepare

  def players_reversed_with_current_last
    players_re = players.dup
    until players_re.first == current_player do
      players_re << players_re.shift
    end
    players_re.reverse
  end

  def invite(player)
    ordering = (playings.pluck(:ordering).max&.+ 1) || 0
    playings.create!(player: player, ordering: ordering)
    hands.create!(player: player)
  end

  private

    def prepare
      Age.order(:level).each do |age|
        stocks.create!(age: age)
      end
    end
end
