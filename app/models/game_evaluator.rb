class GameEvaluator

  def initialize(game)
    @game = game
  end

  def inexecutable?(board)
    return false unless board.active_card.forcing?
    resource = board.active_card.effects.first.resource
    owner_player = board.player
    @game.other_players_than(owner_player).any? { |player|
      count       = player      .resource_counts(@game)[resource] 
      owner_count = owner_player.resource_counts(@game)[resource]
      count >= owner_count
    }
  end
end
