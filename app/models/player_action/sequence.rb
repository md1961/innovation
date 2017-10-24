module PlayerAction

class Sequence

  def initialize(actions = [])
    @actions = actions
    @undo_statements = []
  end

  def add(action)
    @actions << action
  end

  def undo_statement
    @undo_statements.join('; ')
  end

  def perform
    @actions.flat_map { |action|
      action.perform.tap { |action|
        @undo_statements.unshift(action.undo_statement)
      }
    }
  end
end

end
