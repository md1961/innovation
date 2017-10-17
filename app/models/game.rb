class Game < ActiveRecord::Base
  has_many :playings, -> { order(:ordering) }, dependent: :destroy
  has_many :stocks  , -> { order(:age_id  ) }, dependent: :destroy
  has_many :boards  , -> { order(:color_id) }, dependent: :destroy
  has_many :hands                            , dependent: :destroy
  has_many :influences                       , dependent: :destroy
  has_many :conquests                        , dependent: :destroy
  has_many :players, through: :playings
  belongs_to :turn_player   , class_name: 'Player', foreign_key: :turn_player_id
  belongs_to :current_player, class_name: 'Player', foreign_key: :current_player_id

  attr_accessor :undo_statement, :action_options

  after_create :prepare

  BOARD_COLORS = %w[red green blue yellow purple].map { |n| Color.find_by(name_eng: n) }

  NUM_ACTIONS_PER_TURN = 2

  def human?
    players.any?(&:human?)
  end

  def human_player
    players.detect(&:human?)
  end

  def players_ordered_for_display
    player_showing_hand = human? ? human_player : current_player
    players.rotate(players.index(player_showing_hand)).reverse
  end

  def next_player(player)
    ordering = player.playings.find_by(game: self).ordering
    Playing.where('ordering > ?', ordering).first&.player || players.first
  end

  def other_players_than(player)
    players - [player]
  end

  def current_stock
    age = Age.find_by(level: current_player.max_age_on_boards(self))
    non_empty_stock(age)
  end

  def non_empty_stock(age)
    age = Age.find_by(level: 1) unless age
    stocks.joins(:age).where('ages.level >= ?', age.level).detect { |stock| !stock.empty? }
  end

  def conquered?(target)
    type = "#{target.class}Conquest"
    type_attr = :"#{target.class.name.downcase}"
    conquests.exists?(type: type, type_attr => target)
  end

  def switch_player
    current_ordering = Playing.find_by(player: current_player).ordering
    update!(current_player: Playing.where('ordering > ?', current_ordering).first&.player || players.first)
  end

  def to_turn_player
    update!(current_player: turn_player)
  end

  def end_action
    if num_actions_left > 0
      decrement!(:num_actions_left)
    else
      end_turn
    end
  end

  def end_turn
    player = next_player(turn_player)
    update!(
      turn_player:      player,
      num_actions_left: NUM_ACTIONS_PER_TURN,
      current_player:   player,
    )
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
