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
    ['衣服', ["HAND.cards.any? { |c| !AC_COLORS.include?(c.color) }",
              "(AC_COLORS - OTHERS.flat_map { |p| p.active_colors(@game) }.uniq).size > 0"]],
    ['都市国家', ["OTHERS.any? { |p| p.resource_counts(@game)[Resource.stone] >= 4 }"]],
    ['法典', ["!(HAND.cards.map(&:color) & AC_COLORS).empty?"]],
    ['農業', ["!HAND.empty?"]],
    ['哲学', ["BOARDS.any? { |b| b.not_expanded? }",
              "!HAND.empty?"]],
    ['地図作成', ["INFLUENCE.cards.any? { |c| c.age.level == 1 }"]],
    ['数学', ["!HAND.empty?"]],
    ['暦'  , ["INFLUENCE.cards.size > HAND.cards.size"]],
    ['一神論', ["AC_COLORS.size > @game.turn_player.active_colors(@game).size"]],
    ['道路建設', ["HAND.cards.size >= 2"]],
    ['貨幣', ["!HAND.empty?"]],
    ['建築', ["HAND.cards.size >= 2",
              "AC_CARDS.size == 5 && OTHERS.all? { |p| p.active_cards(@game).size < 5 }"]],
    ['運河建設', ["!HAND.empty?"]],
    ['発酵', ["RES_COUNTS[Resource.woods] >= 2"]],
    ['医術', ["!INFLUENCE.empty? && !@game.turn_player.influence_for(@game).empty?"]],
    ['機械', ["turn_hand = @game.turn_player.hand_for(@game); max_age = turn_hand.cards.map(&:age).map(&:level).max; HAND.cards.size - turn_hand.cards.find_all { |c| c.age.level == max_age }.size >= 2",
              "HAND.cards.any? { |c| c.has_resource?('石') } && BOARD_red)&.expandable_left?"]],
    ['封建主義', ["HAND.cards.any? { |c| c.has_resource?('石') }",
                  "BOARD_yellow)&.expandable_left? || BOARD_purple)&.expandable_left?"]],
    ['方位磁石', ["AC_CARDS.any? { |c| c.has_resource?('木') && c.color != Color.green }"]],
    ['工学', ["AC_CARDS.any? { |c| c.has_resource?('石') }",
              "BOARD_red)&.expandable_left?"]],
    ['教育', ["!INFLUENCE.empty?"]],
    ['錬金術', ["RES_COUNTS[Resource.stone] >= 3",
                "HAND.cards.size >= 2"]],
    ['翻訳', ["!INFLUENCE.empty?"]],
    ['紙', ["BOARD_blue&.expandable_left? || BOARD_green&.expandable_left?",
            "BOARDS.any? { |b| b.expanded_left? }"]],
  ].to_h
end
