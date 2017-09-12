module AiPlayerAttributes

  def choose_action(game)
    chooser = ActionChooser.new(game, self)

    chooser.add(PlayerAction::Draw.new(game, self))
    hand_for(game).cards.each do |card|
      chooser.add(PlayerAction::Play.new(game, self, card))
    end
    boards_for(game).reject(&:empty?).each do |board|
      chooser.add(PlayerAction::Execute.new(game, self, board))
    end

    chooser.choose
  end

  class ActionChooser

    def initialize(game, player)
      @game = game
      @player = player
      @options = []
    end

    def add(action)
      @options << Option.new(action)
    end

    def choose
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
