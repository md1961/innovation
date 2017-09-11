module AiPlayerAttributes

  def choose_action(game)
    if boards_for(game).all?(&:empty?)
      hand = hand_for(game)
      if hand.empty?
        PlayerAction::Draw(game, self)
      else
        card = hand.cards.sample
        PlayerAction::Play(game, self, card)
      end
    else
      board = boards_for(game).reject(&:empty?).sample
      PlayerAction::Execute(game, self, board)
    end
  end
end
