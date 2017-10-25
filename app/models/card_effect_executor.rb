class CardEffectExecutor

  def initialize(game)
    @game = game
  end

  def action_preparer(card_title, effect_index)
    h_preparer[card_title]&.at(effect_index) || ->(player) {}
  end

  private

    def h_preparer
      [
        ['牧畜', []],
        ['石工', []],
        ['陶器', [
          ->(player) {
            ge = GameEvaluator.new(@game, player)
            cards = player.hand_for(@game).cards.find_all { |card|
              card.effect_factor_sum(ge) < 200
            }.sort_by { |card| [card.age.level, card.effect_factor_sum(ge)] }[0, 3]
            actions = cards.map { |card| PlayerAction::Reuse.new(@game, player, card) }
            age = Age.find_by(level: cards.size)
            actions << PlayerAction::DrawAndScore.new(@game, player, age) if age
            PlayerAction::Sequence.new(actions)
          },
          ->(player) {
            PlayerAction::Draw.new(@game, player, Age.find_by(level: 1))
          }
        ]],
      ].to_h
    end
end
