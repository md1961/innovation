module PlayerAction

class Sequence

  def initialize(game_evaluator, actions, condition = 'true')
    @game_evaluator = game_evaluator
    @condition = condition
    @actions = actions
  end

  def set_branch(game_evaluator, condition, actions_true, actions_false)
    @branch = Branch.new(game_evaluator, condition, actions_true, actions_false)
  end

  def perform
    if @game_evaluator.boolean_eval(@condition)
      @actions.map(&:perform)
    end
    @branch&.perform
  end

  class Branch

    def initialize(game_evaluator, condition, actions_true, actions_false)
      @game_evaluator = game_evaluator
      @condition = condition
      @actions_true = actions_true
      @actions_false = actions_false
    end

    def perform
      if @game_evaluator.boolean_eval(@condition)
        @actions_true.map(&:perform)
      else
        @actions_false.map(&:perform)
      end
    end
  end
end

end
