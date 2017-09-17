module AiPlayerAttributes

  # TODO: Func to choose most or least valuable cards.
  # TODO: Think which card to play or execute.
  # TODO: Choose to play card more age than max age on board.

  def choose_action(game)
    chooser = ActionChooser.new(game, self)

    Conquest.conquerable_targets(self, game).each do |target|
      chooser.add(PlayerAction::Conquer.new(game, self, target))
    end

    if chooser.empty?
      ge = GameEvaluator.new(game, self)

      chooser.add(PlayerAction::Draw.new(game, self))

      PlayerAction::Play.add_options_to(chooser)

      boards_for(game).reject(&:empty?).each do |board|
        next unless ge.executable?(board)
        pct_weight = !ge.exclusive?(board) ? 50 : 100
        chooser.add(PlayerAction::Execute.new(game, self, board), pct_weight)
      end
    end

    chooser.choose
  end

  class ActionChooser
    attr_reader :game, :player

    def initialize(game, player)
      @game = game
      @player = player
      @options = []
    end

    def empty?
      @options.empty?
    end

    def add(action, pct_weight = 100)
      @options << Option.new(action, DEFAULT_WEIGHT * pct_weight / 100)
    end

    def choose
      return @options.last if @options.size <= 1

      cum_weight = 0
      @options.each do |option|
        cum_weight += option.weight
        option.cum_weight = cum_weight
      end

      random = rand(@options.last.cum_weight)
      @options.each do |option|
        return option.action if random < option.cum_weight
      end
      @options.last.action
    end

    DEFAULT_WEIGHT = 100

    class Option
      attr_reader :action
      attr_accessor :weight, :cum_weight

      def initialize(action, weight = DEFAULT_WEIGHT)
        @action = action
        @weight = weight
      end
    end
  end
end
