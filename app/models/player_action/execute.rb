module PlayerAction

class Execute < Base

  def self.add_options_to(chooser)
    game   = chooser.game
    player = chooser.player
    BoardSelect.build_instances(game, player).each do |board_select|
      chooser.add(new(game, player, board_select), board_select.pct_weight)
    end
  end

  def initialize(game, player, board_select)
    super(game, player)
    @board         = board_select.board
    @effect_factor = board_select.effect_factor
  end

  def perform
  end

  def message_after
    "(!) #{@player} WANTS TO EXECUTE #{@board.active_card}"
  end

  def to_s
    "Exec#{@board.active_card}"
  end

  MIN_FACTOR_FOR_NON_EXCLUSIVE_TO_SURVIVE = 200
  MAX_FACTOR_TO_BE_ZEROED = 50

  class BoardSelect
    attr_reader :board

    def self.build_instances(game, player)
      @@game_evaluator = GameEvaluator.new(game, player)
      player.boards_for(game).map { |board| BoardSelect.new(board) }.tap { |instances|
        @@exclusive_exists = instances.any?(&:exclusive?)
      }
    end

    def initialize(board)
      @board = board
    end

    def executable?
      @is_executable ||= !@board.empty? && @@game_evaluator.executable?(@board)
    end

    def exclusive?
      @is_exclusive ||= @@game_evaluator.exclusive?(@board)
    end

    def effect_factor
      @effect_factor ||= @@game_evaluator.effect_factor(@board)
    end

    def pct_weight
      return 0 unless executable?
      return 0 if @@exclusive_exists && !exclusive? \
                    && effect_factor < MIN_FACTOR_FOR_NON_EXCLUSIVE_TO_SURVIVE
      return 0 if effect_factor <= MAX_FACTOR_TO_BE_ZEROED
      effect_factor
    end
  end
end

end
