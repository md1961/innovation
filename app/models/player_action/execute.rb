module PlayerAction

class Execute < Base

  def self.add_options_to(chooser)
    game   = chooser.game
    player = chooser.player
    ge = GameEvaluator.new(game, player)

    board_selects = player.boards_for(game).map { |board| BoardSelect.new(board, ge) }
    BoardSelect.exclusive_exists = board_selects.any?(&:exclusive?)
    board_selects.each do |bs|
      chooser.add(new(game, player, bs.board), bs.pct_weight)
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

  def to_s
    "Exec#{@board.active_card}"
  end

  MAX_FACTOR_TO_BE_ZEROED = 50

  class BoardSelect
    attr_reader :board
    cattr_accessor :exclusive_exists

    def initialize(board, game_evaluator)
      @board = board
      @game_evaluator = game_evaluator
    end

    def executable?
      @is_executable ||= !@board.empty? && @game_evaluator.executable?(@board)
    end

    def exclusive?
      @is_exclusive ||= @game_evaluator.exclusive?(@board)
    end

    def effect_factor
      @effect_factor ||= @game_evaluator.effect_factor(@board)
    end

    def pct_weight
      return 0 unless executable?
      return 0 if @@exclusive_exists && !exclusive?
      return 0 if effect_factor <= MAX_FACTOR_TO_BE_ZEROED
      effect_factor
    end
  end
end

end
