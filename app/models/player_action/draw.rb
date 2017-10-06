module PlayerAction

class Draw < Base

  def self.add_options_to(chooser)
    game   = chooser.game
    player = chooser.player
    chooser.add(new(game, player))
  end

  def initialize(game, player)
    super
    age_level = @player.max_age_on_boards(@game) || Age.pluck(:level).min
    age = Age.find_by(level: age_level)
    @stock = @game.non_empty_stock(age)
  end

  def no_card?
    @stock.nil?
  end

  def age
    @stock&.age&.level
  end

  def perform
    @player.draw_from(@stock)
  end

  def message_after
    "#{@player} drawed from [#{@stock.age.level}]"
  end

  def to_s
    "Draw[#{age || 'X'}]"
  end
end

end
