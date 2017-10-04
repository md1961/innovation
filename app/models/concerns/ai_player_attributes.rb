module AiPlayerAttributes

  # TODO: Func to choose most or least valuable cards.
  # TODO: Think which card to play or execute.
  # TODO: Choose to play card more age than max age on board.

  def choose_action(game)
    chooser = ActionChooser.new(game, self)

    PlayerAction::Conquer.add_options_to(chooser)
    if chooser.empty?
      PlayerAction::Draw   .add_options_to(chooser)
      PlayerAction::Play   .add_options_to(chooser)
      PlayerAction::Execute.add_options_to(chooser)
    end

    action = chooser.choose
    @action_options = chooser.to_s
    action
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
      return @options.last.action if @options.size <= 1

      adjust_weights
      set_cum_options

      @random = rand(@options.last.cum_weight)
      @options.each do |option|
        return option.action if @random < option.cum_weight
      end
      @options.last.action
    end

    def to_s
      @options.join(' ') + " <= #{@random}"
    end

    DEFAULT_WEIGHT = 100
    MIN_GAP_FOR_WEIGHT_CUTOFF = 200

    class Option
      attr_reader :action
      attr_accessor :weight, :cum_weight

      def initialize(action, weight = DEFAULT_WEIGHT)
        @action = action
        @weight = weight
      end

      def draw?
        @action.is_a?(PlayerAction::Draw)
      end

      def play?
        @action.is_a?(PlayerAction::Play)
      end

      def to_s
        effect_factor = @action.effect_factor
        former_weight = effect_factor && effect_factor != weight ? "#{effect_factor}->" : ''
        "#{@action}(#{former_weight}#{weight})"
      end
    end

    private

      def adjust_weights
        option_draw = @options.find(&:draw?)
        if option_draw
          if @options.none?(&:play?)
            option_draw.weight *= 2
          elsif option_draw.action.age < max_age_of_plays
            option_draw.weight = 0
          end
        end

        weight_cutoff = get_weight_cutoff
        @options.each do |option|
          if option.weight < weight_cutoff
            option.action.effect_factor = option.weight
            option.weight = 0
          end
        end
      end

      def max_age_of_plays
        @max_age_of_plays ||= @options.find_all(&:play?)
          .map(&:action).map(&:card).map(&:age).map(&:level).max
      end

      # TODO: Use lazy initialization in get_weight_cutoff().
      def get_weight_cutoff
        @options.map(&:weight).max - MIN_GAP_FOR_WEIGHT_CUTOFF
      end

      def set_cum_options
        cum_weight = 0
        @options.each do |option|
          cum_weight += option.weight
          option.cum_weight = cum_weight
        end
      end
  end
end
