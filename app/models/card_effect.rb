class CardEffect < ActiveRecord::Base
  belongs_to :card
  belongs_to :resource

  def conditional_on_effect_above?
    content.starts_with?('上記の優越型教義により')
  end

  def executable?(game_evaluator)
    game_evaluator.instance_eval(condition)
  end

  def condition
    index = card.effects.index(self)
    conditions = [
      ['道具', ['@player.hand_for(@game).empty?']]
    ].to_h[card.title]
    (conditions && conditions[index]) || 'true'
  end
end
