module AiPlayerAttributes

  # TODO: Func to choose least valuable cards.
  # TODO: Think which card to play or execute.
  # TODO: Add option to conquer Age or Category.

  def choose_action(game)
    chooser = ActionChooser.new(game, self)

    Conquest.conquerable_targets(self, game).each do |target|
      chooser.add(PlayerAction::Conquer.new(game, self, target))
    end

    if chooser.empty?
      ge = GameEvaluator.new(game, self)

      chooser.add(PlayerAction::Draw.new(game, self))
      hand_for(game).cards.each do |card|
        chooser.add(PlayerAction::Play.new(game, self, card))
      end
      boards_for(game).reject(&:empty?).each do |board|
        next unless ge.executable?(board)
        chooser.add(PlayerAction::Execute.new(game, self, board))
      end
    end

    chooser.choose
  end

  class ActionChooser

    def initialize(game, player)
      @game = game
      @player = player
      @options = []
    end

    def empty?
      @options.empty?
    end

    def add(action)
      @options << Option.new(action)
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
