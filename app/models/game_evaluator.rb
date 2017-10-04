class GameEvaluator
  attr_reader :player

  def initialize(game, player)
    @game = game
    @player = player
  end

  def boolean_eval(statement, resource = nil, is_for_all = true)
    if is_for_all
      instance_eval(apply_macros(statement))
    else
      player_in_turn = @player
      others = @game.other_players_than(@player)
      result = others.any? { |player|
        @player = player
        less_resource?(player, resource, player_in_turn) && instance_eval(apply_macros(statement))
      }
      @player = player_in_turn
      result
    end
  end

    def less_resource?(player, resource, player_in_turn)
      player.resource_counts(@game)[resource] < player_in_turn.resource_counts(@game)[resource]
    end

  def factor_eval(statement, resource, is_for_all = true)
    if is_for_all
      instance_eval(apply_macros(statement)).ceil
    else
      player_in_turn = @player
      others = @game.other_players_than(@player)
      result = others.inject(0) { |sum, player|
        @player = player
        if less_resource?(player, resource, player_in_turn)
          sum += instance_eval(apply_macros(statement)).ceil
        end
      }
      @player = player_in_turn
      result || 0
    end
  end

  def executable?(board)
    card = board.active_card
    return false if card.nil? || card.effects.none? { |effect| effect.executable?(self) }
    resource = card.effects.first.resource
    num_players_with_more_resource = players_with_more_resource_than(board.player, resource).size
    !(card.forcing? && num_players_with_more_resource >= 1)
  end

  def exclusive?(board)
    card = board.active_card
    return false unless card && executable?(board)
    resource = card.effects.first.resource
    players_with_more_resource = players_with_more_resource_than(board.player, resource)
    return true if players_with_more_resource.size.zero?
    players_with_more_resource.none? { |player|
      ge = self.class.new(@game, player)
      card.effects.any? { |effect| effect.executable?(ge) }
    }
  end

  def effect_factor(board)
    return 0 unless board.active_card
    board.active_card.effects.map { |effect| effect.effect_factor(self) }.sum
  end

  def max_age_updatable?
    @player.hand_for(@game).max_age > @player.active_cards(@game).map(&:age).map(&:level).max
  end

  def decrease_active_card_age?(card)
    board = @player.boards_for(@game).find_by(color: card.color)
    return false unless board.active_card
    card.age.level < board.active_card.age.level
  end

  private

    def players_with_more_resource_than(this_player, resource)
      this_count = this_player.resource_counts(@game)[resource]
      @game.other_players_than(this_player).find_all { |player|
        count = player.resource_counts(@game)[resource]
        count >= this_count
      }
    end

    def apply_macros(statement)
      s = statement.dup
      MACRO_REPLACEMENTS.each do |name, replacement|
        s.gsub!(/(?<!::)\b#{name}\b/, replacement)
      end
      s
    end

    MACRO_REPLACEMENTS = [
      ['BOARD_([a-z]+)', "BOARDS.find_by(color: Color.\\1)" ],
      ['HAND'          , "@player.hand_for(@game)"          ],
      ['OTHERS'        , "@game.other_players_than(@player)"],
      ['BOARDS'        , "@player.boards_for(@game)"        ],
      ['RES_COUNTS'    , "@player.resource_counts(@game)"   ],
      ['AC_CARDS'      , "@player.active_cards(@game)"      ],
      ['AC_COLORS'     , "@player.active_colors(@game)"     ],
      ['INFLUENCE'     , "@player.influence_for(@game)"     ],
      ['CONQUEST'      , "10000"                            ],
      ['VICTORY'       , "1000000"                          ],
    ]
end
