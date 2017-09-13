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
    conditions = H_CONDITIONS[card.title]
    (conditions && conditions[index]) || 'true'
  end

  H_CONDITIONS = [
    ['牧畜', ["!@player.hand_for(@game).empty?"]],
    ['石工', ["@player.hand_for(@game).cards.any? { |c| c.has_resource?('石') }"]],
    ['陶器', ["!@player.hand_for(@game).empty?"]],
    ['道具', ["@player.hand_for(@game).cards.size >= 3",
              "@player.hand_for(@game).cards.map(&:age).map(&:level).include?(3)"]],
    ['衣服', ["@player.hand_for(@game).cards.any? { |c| !@player.active_colors(@game).include?(c.color) }",
              "(@player.active_colors(@game) - @game.other_players_than(@player).flat_map { |p| p.active_colors(@game) }.uniq).size > 0"]],
    ['都市国家', ["@game.other_players_than(@player).any? { |p| p.resource_counts(@game)[Resource.find_by(name: '石')] >= 4 }"]],
    ['法典', ["!(@player.hand_for(@game).cards.map(&:color) & @player.active_colors(@game)).empty?"]],
    ['農業', ["!@player.hand_for(@game).empty?"]],

    # 16.tap { |id| c = Card.find(id); puts c, c.effects.size, c.effects.map(&:content) }
  ].to_h
end
