class CardEffectExecutor

  def initialize(game, player)
    @game = game
    @player = player
  end

  def prepare_actions(action_preparing_statements)
    statement, condition = action_preparing_statements
    statement = '[]' unless statement
    instance_eval(statement)
  end
end
