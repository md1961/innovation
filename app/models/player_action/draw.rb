module PlayerAction

class Draw < Base

  def perform
    age_level = @player.max_age_on_boards(@game) || Age.pluck(:level).min
    age = Age.find_by(level: age_level)
    @stock = @game.stocks.find_by(age: age)
    while @stock.empty? do
      @stock = @game.stocks.find_by(age: @stock.age.next)
    end
    @player.draw_from(@stock)
  end

  def message_after
    "#{@player} drawed from [#{@stock.age.level}]}"
  end
end

end
