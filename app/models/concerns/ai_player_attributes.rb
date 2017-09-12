module AiPlayerAttributes

  def choose_action(game)
    options = [PlayerAction::Draw.new(game, self)]
    options.concat(
      hand_for(game).cards.map {
        |card| PlayerAction::Play.new(game, self, card)
      }
    )
    options.concat(
      boards_for(game).reject(&:empty?).map {
        |board| PlayerAction::Execute.new(game, self, board)
      }
    )
    options.sample
  end
end
