module PlayerAction

class Execute < Base

  def self.add_options_to(chooser)
    game   = chooser.game
    player = chooser.player
    ge = GameEvaluator.new(game, player)

    player.boards_for(game).reject(&:empty?).each do |board|
      next unless ge.executable?(board)
      pct_weight = !ge.exclusive?(board) ? 50 : 100
      chooser.add(new(game, self, board), pct_weight)
    end
  end

  def initialize(game, player, board)
    super(game, player)
    @board = board
  end

  def perform
  end

  def message_after
    "(!) #{@player} WANTS TO EXECUTE #{@board.active_card}"
  end
end

end
