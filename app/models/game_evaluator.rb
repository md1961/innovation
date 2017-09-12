class GameEvaluator

  def initialize(game, player)
    @game = game
    @player = player
  end

  def inexecutable?(board)
    return false unless board.active_card.forcing?
    resource = board.active_card.effects.first.resource
    players_with_more_resource_than(board.player, resource).size >= 1
  end

  def players_with_more_resource_than(this_player, resource)
    this_count = this_player.resource_counts(@game)[resource]
    @game.other_players_than(this_player).find_all { |player|
      count = player.resource_counts(@game)[resource]
      count >= this_count
    }
  end
end
