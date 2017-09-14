module PlayerAction

class Conquer < Base

  def initialize(game, player, target)
    super(game, player)
    @target = target
  end

  def perform
    @player.conquer(@target, @game)
  end

  def message_after
    "#{@player} conquered #{@target}"
  end
end

end
