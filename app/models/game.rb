class Game < ActiveRecord::Base
  has_many :playings, -> { order(:ordering) }, dependent: :destroy
  has_many :stocks  , -> { order(:age_id  ) }, dependent: :destroy
  has_many :boards  , -> { order(:color_id) }, dependent: :destroy
  has_many :hands                            , dependent: :destroy
  has_many :influences                       , dependent: :destroy
  has_many :players, through: :playings
  belongs_to :current_player, class_name: 'Player', foreign_key: :current_player_id

  after_create :prepare

  BOARD_COLORS = %w[red green blue yellow purple].map { |n| Color.find_by(name_eng: n) }

  NUM_ACTIONS_PER_TURN = 2

  def players_reversed_with_current_last
    players_dup = players.to_a
    until players_dup.first == current_player do
      players_dup << players_dup.shift
    end
    players_dup.reverse
  end

  def next_player(player)
    ordering = player.playings.find_by(game: self).ordering
    Playing.where('ordering > ?', ordering).first&.player || players.first
  end

  def end_action
    if num_actions_left > 0
      decrement!(:num_actions_left)
    else
      end_turn
    end
  end

  def end_turn
    current_ordering = Playing.find_by(player: current_player).ordering
    self.current_player = Playing.where('ordering > ?', current_ordering).first&.player || players.first
    self.num_actions_left = NUM_ACTIONS_PER_TURN
    save!
  end

  def invite(player)
    ordering = (playings.pluck(:ordering).max&.+ 1) || 0
    playings  .create!(player: player, ordering: ordering)
    hands     .create!(player: player)
    influences.create!(player: player)
    BOARD_COLORS.each do |color|
      boards.create!(player: player, color: color)
    end
  end

  private

    def prepare
      Age.order(:level).each do |age|
        stocks.create!(age: age)
      end
    end
end
