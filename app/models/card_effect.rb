class CardEffect < ActiveRecord::Base
  belongs_to :card
  belongs_to :resource

  def conditional_on_effect_above?
    content.starts_with?('上記の優越型教義により')
  end

  def executable?(game_evaluator)
    game_evaluator.eval(condition)
  end

  def condition
    index = card.effects.index(self)
    conditions = H_CONDITIONS[card.title]
    (conditions && conditions[index]) || 'true'
  end

  H_CONDITIONS = [
    ['牧畜', ["!HAND.empty?"]],
    ['石工', ["HAND.cards.any? { |c| c.has_resource?('石') }"]],
    ['陶器', ["!HAND.empty?"]],
    ['道具', ["HAND.cards.size >= 3",
              "HAND.cards.map(&:age).map(&:level).include?(3)"]],
    ['衣服', ["HAND.cards.any? { |c| !@player.active_colors(@game).include?(c.color) }",
              "(@player.active_colors(@game) - OTHERS.flat_map { |p| p.active_colors(@game) }.uniq).size > 0"]],
    ['都市国家', ["OTHERS.any? { |p| p.resource_counts(@game)[Resource.find_by(name: '石')] >= 4 }"]],
    ['法典', ["!(HAND.cards.map(&:color) & @player.active_colors(@game)).empty?"]],
    ['農業', ["!HAND.empty?"]],

    # 16.tap { |id| c = Card.find(id); puts c, c.effects.size, c.effects.map(&:content) }
  ].to_h
end
