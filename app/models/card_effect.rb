class CardEffect < ActiveRecord::Base
  belongs_to :card
  belongs_to :resource

  def conditional_on_effect_above?
    content.starts_with?('上記の優越型教義により')
  end

  def executable?(game_evaluator)
    game_evaluator.boolean_eval(necessary_condition, resource, is_for_all)
  end

  def necessary_condition
    condition(H_NECESSARY_CONDITIONS)
  end

  def effect_factor(game_evaluator, assumes_executable = false)
    return 0 unless executable?(game_evaluator) || assumes_executable
    game_evaluator.factor_eval(evaluation_f, resource, is_for_all)
  end

  def evaluation_f
    index = card.effects.index(self)
    evaluation_fs = H_EVALUATION_F[card.title]
    (evaluation_fs && evaluation_fs[index]) || '100'
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
              "HAND.cards.any? { |c| c.age.level == 3 }"]],
    ['衣服', ["HAND.cards.any? { |c| !AC_COLORS.include?(c.color) }",
              "(AC_COLORS - OTHERS.flat_map { |p| p.active_colors(@game) }.uniq).size > 0"]],
    ['都市国家', ["OTHERS.any? { |p| p.resource_counts(@game)[Resource.stone] >= 4 }"]],
    ['法典', ["!(HAND.cards.map(&:color) & AC_COLORS).empty?"]],
    ['農業', ["!HAND.empty?"]],
    ['哲学', ["BOARDS.any? { |b| b.expandable_left? }",
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
    ['機械', ["turn_hand = @game.turn_player.hand_for(@game); max_age = turn_hand.max_age; HAND.cards.size - turn_hand.cards.find_all { |c| c.age.level == max_age }.size >= 2",
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
    ['分類', ["@game.players.any? { |p| !p.hand_for(@game).empty? }"]],
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
    ['量子論', ["!HAND.empty?"]],
    ['ロケット工学', ["RES_COUNTS[Resource.time] >= 2"]],
    ['飛行機', ["BOARD_red&.expanded_upward? && BOARDS.any? { |b| b.color != Color.red && b.expandable_upward? }",
                "BOARD_red&.expandable_upward?"]],
    ['経験論', ["BOARDS.any?(&:expandable_upward?)",
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
    ['核分裂', ["@game.players.flat_map { |p| p.active_cards(@game) }.find_all { |c| c.age.level == 10 && c.color == Color.red } == 2"]],
    ['コンピューター', ["BOARD_red&.expandable_upward? || BOARD_green&.expandable_upward?"]],
    ['人工衛星', [nil,
                  "BOARD_purple&.expandable_upward?",
                  "HAND.cards.any? { |c| c.effects.any?(&:is_for_all) }"]],
    ['専門化', ["!HAND.empty?",
                "BOARD_yellow&.expandable_upward? || BOARD_blue&.expandable_upward?"]],
    ['住宅地', ["!HAND.empty?"]],
    ['エコロジー', ["HAND.cards.size >= 2"]],
    ['小型化', ["!HAND.empty?"]],
    ['提携', [nil,
              "BOARD_green.cards.size >= 10"]],
    ['人工知能', [nil,
                  "[Card.find_by(title: 'ロボット工学'), Card.find_by(title: 'ソフトウェア')].all? { |c| c.card_list(@game).is_a?(Board) }"]],
    ['インターネット', ["BOARD_green&.expandable_upward?",
                        nil,
                        "RES_COUNTS[Resource.time] >= 2"]],
    ['データベース', ["INFLUENCE.cards.size >= 2"]],
    ['グローバル化', ["AC_CARDS.any? { |c| c.has_resource?('木') }"]],
    ['ホームオートメーション', ["AC_CARDS.any? { |c| c.title != 'ホームオートメーション' && c.effects.any? { |e| e.is_for_all && e.executable?(self) } }"]],
    ['生物工学', ["OTHERS.any? { |p| p.active_cards(@game).any? { |c| c.has_resource?('木') } }",
                  "@game.players.any? { |p| p.resource_counts(@game)[Resource.woods] <= 3 }"]],
    ['幹細胞', ["!HAND.empty?"]],
  ].to_h

  H_EVALUATION_F = [
    ['石工', ["n = HAND.cards.find_all { |c| c.has_resource?('石') }.size; n >= 4 ? CONQUEST : (n - 1) * 50 + 100"]],
    ['弓矢', ["(HAND.max_age - 1) * 100 + 100"]],
    ['筆記', ["150"]],
    ['陶器', ["(HAND.cards.size - 1) * 50 + 100"]],
    ['道具', ["(HAND.cards.size - 3) * 25 + 200",
              "HAND.cards.any? { |c| c.age.level == 3 } ? 150 : 0"]],
    ['神秘主義', ["(BOARDS.count { |b| !b.empty? } - 1) * 25 + 100"]],
    ['衣服', ["(HAND.cards.find_all { |c| !AC_COLORS.include?(c.color) }.map(&:age).map(&:level).max || 0 - 1) * 50 + 100",
              "((AC_COLORS - OTHERS.flat_map { |p| p.active_colors(@game) }.uniq).size - 1) * 50 + 150"]],
    ['都市国家', ["(AC_CARDS.find_all { |c| c.has_resource?('石') }.map(&:age).map(&:level).min || 0 - 1) * 50 + 150"]],
    ['金属加工', ["150"]],
    ['法典', ["colors = HAND.cards.map(&:color); (BOARDS.find_all { |b| colors.include?(b.color) && b.expandable_left? }.map(&:cards).map(&:size).max || 0) * 50 + 50"]],
    ['農業', ["HAND.max_age * 50 + (HAND.cards.size - 1) * 50"]],
#!!!
    ['予防接種', ["(INFLUENCE.cards.size - 1) * 100 / 3 + 100"]],
    ['民主主義', ["(HAND.cards.find_all { |c| c.age.level < @player.max_age_on_boards(@game) }.size - 1) * 100 / 3 + 100"]],
    ['メートル法', ["((BOARDS.find_all { |b| b.color != Color.green && b.expandable_right? }.map { |b| b.cards.size }.max || 0) - 2) * 100 / 3 + 100",
                    "(BOARD_green.cards.size - 2) * 100 / 3 + 100"]],
    ['百科事典', ["(INFLUENCE.cards.size - 1) * 100 / 3 + 100"]],
    ['缶詰', ["(BOARDS.find_all(&:active_card_decreasing_age?).size - 1) * 100 + 200"]],
    ['産業化', ["((RES_COUNTS[Resource.manufacture] / 2).floor - 1) * 100 + 100",
                "(([BOARD_red, BOARD_purple].find_all(&:expandable_right?).map { |b| b.cards.size }.max || 0) - 2) * 100 / 3 + 100"]],
    ['工作機械', ["[(INFLUENCE.max_age - 3) * 100 + 100, 100].max"]],
    ['原理理論', ["(BOARD_blue.cards.size - 2) * 100 / 3 + 100",
                  "AC_CARDS.all? { |c| c.age.level >= 8 } ? -100 : 100"]],
    ['奴隷解放', ["(HAND.cards.size - 1) * 25 + 100",
                  "(([BOARD_red, BOARD_purple].find_all(&:expandable_right?).map { |b| b.cards.size }.max || 0) - 2) * 100 / 3 + 100"]],
    ['分類', ["(OTHERS.all? { |p| !p.hand_for(@game).empty? } ? 25 : 0) + ((HAND.cards.size - 2) * 25 + 50) + ((OTHERS.map { |p| p.hand_for(@game).cards.size }.sum - OTHERS.size * 2) * 25 + 25)"]],
    ['冷蔵', ["((HAND.cards.size / 2).floor - 1) * 50 + 100",
              "(HAND.cards.size - 1) * 25 + 100"]],
    ['進化論', ["(INFLUENCE.cards.size - 1) * 25 + 100"]],
    ['出版', ["(BOARDS.reject(&:empty?).map { |b| b.max_age - b.active_card.age.level }.max - 1) * 50 + 100",
              "(([BOARD_yellow, BOARD_blue].find_all(&:expandable_upward?).map { |b| b.cards.size }.max || 0) - 2) * 100 / 3 + 200"]],
    ['自転車', []],  # TODO
    ['公衆衛生', ["((HAND.cards.size - 2) * 25 + 50) + [(((@game.turn_player.hand_for(@game).min_age || 10) - 5) * -50 + 50), 50].max"]],
    ['鉄道', ["(HAND.cards.find_all { |c| c.age.level < @player.max_age_on_boards(@game) }.size - 1) * 100 / 3 + 100",
              "((BOARDS.find_all(&:expanded_right?).map { |b| b.cards.size }.max || 0) - 2) * 100 / 3 + 200"]],
    ['内燃機関', []],  # TODO
    ['爆薬', ["(HAND.cards.size - 3) * 100 / 3 + 100"]],
    ['街灯', ["(HAND.cards.find_all { |c| c.age.level < @player.max_age_on_boards(@game) }.size - 1) * 100 / 3 + 100"]],
    ['電気', ["boards = BOARDS.reject(&:empty?).find_all { |b| !b.active_card.has_resource?('製造') }; num_good = boards.count { |b| b.active_card_decreasing_age? }; diff = num_good - (boards.size - num_good); (diff - 1) * 100 + 100"]],
    ['企業', ["BOARDS.reject(&:empty?).any? { |b| b.active_card.has_resource?('製造') && b.color != Color.green && (b.active_card.age.level == @player.max_age_on_boards(@game) || !b.active_card_decreasing_age?) } ? 200 : 0"]],
    ['量子論', ["n = HAND.cards.find_all { |c| c.age.level < @player.max_age_on_boards(@game) }.size; n < 2 ? 0 : (n - 1) * 100 / 3 + 100"]],
    ['ロケット工学', ["((RES_COUNTS[Resource.time] / 2).floor - 1) * 100 + 100"]],
    ['飛行機', ["((BOARDS.find_all { |b| b.color != Color.red && b.expandable_upward? }.map { |b| b.cards.size }.max || 0) - 2) * 100 / 3 + 200",
                "(BOARD_red.cards.size - 2) * 100 / 3 + 200"]],
    ['経験論', ["BOARDS.find_all(&:expandable_upward?).size >= 2 ? 150 : 100",
                "VICTORY"]],
    ['摩天楼', ["([((AC_CARDS.find_all { |c| c.has_resource?('時間') && c.color != Color.yellow }.map(&:age).map(&:level).min || 0) - 7) * 50 + 50, 25].max) + ([((BOARDS.reject(&:empty?).find_all { |b| b.active_card.has_resource?('時間') && b.color != Color.yellow }.map(&:cards).map(&:size).min || 0) - 5) * 25 + 50, 25].max)"]],
    ['共産主義', ["cards = HAND.cards.find_all { |c| c.age.level < @player.max_age_on_boards(@game) }; cards.size.zero? ? 0 : ((cards.size - 1) * 100 / 3 + 100) + (cards.any? { |c| c.color == Color.purple } ? 50 : 0)"]],
    ['抗生物質', ["((HAND.cards.size - 2) * 10 + 50) + ((HAND.cards.map(&:age).map(&:level).uniq.size - 3) * 25 + 50)"]],
    ['交通', ["[((AC_CARDS.find_all { |c| !c.has_resource?('製造') && c.color != Color.red }.map(&:age).map(&:level).sort.reverse[1] || 0) - 6) * 50 + 100, 100].max"]],
    ['マスメディア', ["(OTHERS.map { |p| p.influence_for(@game).cards.size }.min - 5) * 25 + 100",
                      "(BOARD_purple.cards.size - 2) * 100 / 3 + 200"]],
    ['提携', ["((AC_CARDS.find_all { |c| c.age.level > 9 }.size - 1) * 50 + 50) + ((@game.turn_player.active_cards(@game).find_all { |c| c.age.level < 9 }.size - 1) * 50 + 50)",
              "VICTORY"]],
    ['複合材料', ["((HAND.cards.size - 2) * 25 + 100) + (INFLUENCE.cards.size * 10)"]],
    ['サービス業', ["ac_size = @game.turn_player.active_cards(@game).find_all { |c| !c.has_resource?('木') }.size; ((INFLUENCE.cards.size - 1) * 25 + 100) + (ac_size.zero? ? 100 : (ac_size - 2) * 25)"]],
    ['コンピューター', ["(([BOARD_red, BOARD_green].find_all(&:expandable_upward?).map { |b| b.cards.size }.max || 0) - 2) * 100 / 3 + 200"]],
    ['人工衛星', ["HAND.cards.size * -25 + 150",
                  "(BOARD_purple.cards.size - 2) * 100 / 3 + 200",
                  "((HAND.cards.map { |c| c.effects.count(&:is_for_all) }.max || 0) - 1) * 50 + 100"]],
    ['専門化', ["(HAND.cards.map(&:color).uniq.map { |color| OTHERS.map { |p| p.active_cards(@game).find { |c| c.color = color } }.map(&:age).map(&:level).sum * 1.0 / OTHERS.size }.max - 8) * 50 + 100",
                "(([BOARD_yellow, BOARD_blue].find_all(&:expandable_upward?).map { |b| b.cards.size }.max || 0) - 2) * 100 / 3 + 200"]],
    ['住宅地', ["(HAND.cards.size - 2) * 100 / 3 + 100"]],
    ['エコロジー', ["(HAND.cards.size - 2) * 100 / 3 + 100"]],
    ['小型化', ["HAND.max_age == 10 ? 150 + INFLUENCE.cards.map(&:age).map(&:level).uniq.size * 20 : 0"]],
    ['ロボット工学', ["(BOARD_green.active_card.age.level * 10) + (BOARD_green.active_card_decreasing_age? ? 100 : 50)"]],
    ['人工知能', ["200",
                  "OTHERS.all? { |p| p.influence_point(@game) > @player.influence_point(@game) } ? VICTORY : 0"]],
    ['インターネット', ["(BOARD_green.cards.size - 2) * 100 / 3 + 200",
                        "200",
                        "((RES_COUNTS[Resource.time] / 2).floor - 1) * 100 + 100"]],
    ['データベース', ["[((INFLUENCE.cards.size / 2).floor - 1) * 50, 0].max"]],
    ['グローバル化', ["100",
                      "@game.players.none? { |p| r_counts = p.resource_counts(@game); r_counts[Resource.woods] > r_counts[Resource.manufacture] } && OTHERS.all? { |p| p.influence_point(@game) < @player.influence_point(@game) } ? VICTORY : 0"]],
    ['ソフトウェア', ["100",
                      "200"]],
    # TODO: Use factor func for['ホームオートメーション', ["AC_CARDS.any? { |c| c.title != 'ホームオートメーション' && c.effects.any? { |e| e.is_for_all } }"]],
    ['生物工学', ["((OTHERS.flat_map { |p| p.active_cards(@game) }.find_all { |c| c.has_resource?('木') }.map(&:age).map(&:level).max || 0) - 7) * 50 + 100",
                  "OTHERS.all? { |p| p.resource_counts(@game)[Resource.woods] < RES_COUNTS[Resource.woods] } ? VICTORY : 0"]],
    ['幹細胞', ["HAND.cards.map(&:age).map(&:level).sum * 10"]],
  ].to_h
end
