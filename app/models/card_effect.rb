class CardEffect < ActiveRecord::Base
  belongs_to :card
  belongs_to :resource

  def conditional_on_effect_above?
    content.starts_with?('上記の優越型教義により')
  end

  def executable?(game_evaluator)
    game_evaluator.eval(necessary_condition, is_for_all)
  end

  def favorable?(game_evaluator)
    game_evaluator.eval(favorable_condition, is_for_all)
  end

  def necessary_condition
    condition(H_NECESSARY_CONDITIONS)
  end

  def favorable_condition
    condition(H_FAVORABLE_CONDITIONS)
  end

  private

    def condition(h_data)
      index = card.effects.index(self)
      conditions = h_data[card.title]
      (conditions && conditions[index]) || 'true'
    end

  H_NECESSARY_CONDITIONS = [
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
              "HAND.cards.any? { |c| c.has_resource?('石') } && BOARD_red&.expandable_left?"]],
    ['封建主義', ["HAND.cards.any? { |c| c.has_resource?('石') }",
                  "BOARD_yellow&.expandable_left? || BOARD_purple&.expandable_left?"]],
    ['方位磁石', ["AC_CARDS.any? { |c| c.has_resource?('木') && c.color != Color.green }"]],
    ['工学', ["AC_CARDS.any? { |c| c.has_resource?('石') }",
              "BOARD_red&.expandable_left?"]],
    ['教育', ["!INFLUENCE.empty?"]],
    ['錬金術', ["RES_COUNTS[Resource.stone] >= 3",
                "HAND.cards.size >= 2"]],
    ['翻訳', ["!INFLUENCE.empty?"]],
    ['紙', ["BOARD_blue&.expandable_left? || BOARD_green&.expandable_left?",
            "BOARDS.any? { |b| b.expanded_left? }"]],
    ['事業', ["AC_CARDS.any? { |c| c.has_resource?('金属') && c.color != Color.purple }",
              "BOARD_green.expandable_right?"]],
    ['航海術', ["INFLUENCE.cards.any? { |c| c.age.level.between?(2, 3) }"]],
    ['印刷機', ["!INFLUENCE.empty?",
                "BOARD_blue.expandable_right?"]],
    ['発明', ["BOARDS.any? { |b| b.expanded_left? }",
              "BOARDS.all? { |b| b.expanded? }"]],
    ['遠近法', ["!HAND.empty?"]],
    ['解剖学', ["!INFLUENCE.empty?"]],
    ['改革', ["RES_COUNTS[Resource.woods] >= 2",
              "BOARD_yellow&.expandable_right? || BOARD_purple&.expandable_right?"]],
    ['火薬', ["AC_CARDS.any? { |c| c.has_resource?('石') }"]],
    ['化学', ["BOARD_blue&.expandable_right?"]],
    ['社交界', ["AC_CARDS.any? { |c| c.has_resource?('電気') && c.color != Color.purple }"]],
    ['銀行', ["AC_CARDS.any? { |c| c.has_resource?('製造') && c.color != Color.green }"]],
    ['計測', ["!HAND.empty? && BOARDS.any? { |b| b.expandable_right? }"]],
    ['石炭', [nil,
              "BOARD_red&.expandable_right?",
              "BOARDS.any? { |b| b.cards.size >= 2 }"]],
    ['天文学', [nil,
                "AC_CARDS.all? { |c| c.color == Color.purple || c.age.level >= 6 }"]],
    ['海賊典範', ["INFLUENCE.cards.any? { |c| c.age.level <= 4 }"]],
    ['統計', ["!INFLUENCE.empty?",
              "BOARD_yellow&.expandable_right?"]],
    ['予防接種', ["!INFLUENCE.empty?"]],
    ['民主主義', ["HAND.cards.size > OTHERS.map { |p| p.hand_for(@game) }.map(&:cards).map(&:size).max"]],
    ['メートル法', ["BOARD_green&.expanded_right? && BOARDS.any? { |b| b.color != Color.green && b.expandable_right? }",
                    "BOARD_green&.expandable_right?"]],
    ['百科事典', ["!INFLUENCE.empty?"]],
    ['缶詰', [nil,
              "BOARD_yellow&.expandable_right?"]],
    ['産業化', ["RES_COUNTS[Resource.manufacture] >= 2",
                "BOARD_red&.expandable_right? || BOARD_purple&.expandable_right?"]],
    ['工作機械', ["!INFLUENCE.empty?"]],
    ['原理理論', ["BOARD_blue&.expandable_right?"]],
    ['奴隷解放', ["!HAND.empty?",
                  "BOARD_red&.expandable_right? || BOARD_purple&.expandable_right?"]],
    ['分類', ["!HAND.empty?"]],
    ['冷蔵', ["HAND.cards.size >= 2",
              "!HAND.empty?"]],
    ['進化論', ["!INFLUENCE.empty?"]],
    ['出版', ["BOARDS.any? { |b| b.cards.size >= 2 }",
              "BOARD_yellow&.expandable_upward? || BOARD_blue&.expandable_upward?"]],
    ['自転車', ["!HAND.empty? && !INFLUENCE.empty?"]],
    ['公衆衛生', ["HAND.cards.size >= 2 && @game.turn_player.hand_for(@game).cards.size >= 1"]],
    ['鉄道', ["!HAND.empty?",
              "BOARDS.any? { |b| b.expanded_right? }"]],
    ['内燃機関', ["INFLUENCE.cards.size >= 2"]],
    ['爆薬', ["!HAND.empty?"]],
    ['街灯', ["!HAND.empty?"]],
    ['電気', ["AC_CARDS.any? { |c| !c.has_resource?('製造') }"]],
    ['企業', ["AC_CARDS.any? { |c| c.has_resource?('製造') && c.color != Color.green }"]],
    ['量子論', ["HAND.cards.size >= 2"]],
    ['ロケット工学', ["RES_COUNTS[Resource.time] >= 2"]],
    ['飛行機', ["BOARD_red&.expanded_upward? && BOARDS.any? { |b| b.color != Color.red && b.expandable_upward? }",
                "BOARD_red&.expandable_upward?"]],
    ['経験論', [nil,
                "RES_COUNTS[Resource.electricity] >= 20"]],
    ['摩天楼', ["AC_CARDS.any? { |c| c.has_resource?('時間') && c.color != Color.yellow }"]],
    ['共産主義', ["!HAND.empty?"]],
    ['抗生物質', ["!HAND.empty?"]],
    ['交通', ["AC_CARDS.any? { |c| !c.has_resource?('製造') && c.color != Color.red }"]],
    ['マスメディア', ["!HAND.empty?",
                      "BOARD_purple&.expandable_upward?"]],
    ['提携', [nil,
              "BOARD_green.cards.size >= 10"]],
    ['複合材料', ["HAND.cards.size >= 2 && !INFLUENCE.empty?"]],
    ['サービス業', ["!INFLUENCE.empty?"]],
    ['コンピューター', ["BOARD_red&.expandable_upward? || BOARD_green&.expandable_upward?"]],
    ['人工衛星', ["!HAND.empty?",
                  "BOARD_purple&.expandable_upward?",
                  "!HAND.empty?"]],
    ['専門化', ["!HAND.empty?",
                "BOARD_yellow&.expandable_upward? || BOARD_blue&.expandable_upward?"]],
    ['住宅地', ["!HAND.empty?"]],
    ['エコロジー', ["!HAND.empty?"]],
    ['小型化', ["!HAND.empty?"]],
    ['提携', ["!BOARD_green.cards.empty?"]],
    ['人工知能', [nil,
                  "[Card.find_by(title: 'ロボット工学'), Card.find_by(title: 'ソフトウェア')].all? { |c| c.card_list(@game).is_a?(Board) }"]],
    ['インターネット', ["BOARD_green&.expandable_upward?",
                        nil,
                        "RES_COUNTS[Resource.time] >= 2"]],
    ['データベース', ["INFLUENCE.cards.size >= 2"]],
    ['グローバル化', ["AC_CARDS.any? { |c| c.has_resource?('木') }"]],
    ['ホームオートメーション', ["AC_CARDS.any? { |c| c.title != 'ホームオートメーション' && c.effects.any? { |e| e.is_for_all } }"]],
    ['生物工学', ["OTHERS.any? { |p| p.active_cards(@game).any? { |c| c.has_resource?('木') } }",
                  "@game.players.any? { |p| p.resource_counts(@game)[Resource.woods] <= 3 }"]],
    ['幹細胞', ["!HAND.empty?"]],
  ].to_h

  H_FAVORABLE_CONDITIONS = [
    ['予防接種', ["INFLUENCE.cards.size >= 4"]],
    ['民主主義', ["HAND.cards.size > OTHERS.map { |p| p.hand_for(@game) }.map(&:cards).map(&:size).max + 2"]],
  ].to_h
end
