class GameEvaluator

  def initialize(game, player)
    @game = game
    @player = player
  end

  def eval(statement)
    instance_eval(apply_macros(statement))
  end

  def executable?(board)
    card = board.active_card
    return false if card.effects.none? { |effect| effect.executable?(self) }
    resource = card.effects.first.resource
    num_players_with_more_resource = players_with_more_resource_than(board.player, resource).size
    !(card.forcing? && num_players_with_more_resource >= 1)
  end

  def exclusive?(board)
    resource = board.active_card.effects.first.resource
    players_with_more_resource_than(board.player, resource).size.zero?
  end

  def players_with_more_resource_than(this_player, resource)
    this_count = this_player.resource_counts(@game)[resource]
    @game.other_players_than(this_player).find_all { |player|
      count = player.resource_counts(@game)[resource]
      count >= this_count
    }
  end

  private

    def apply_macros(statement)
      s = statement.dup
      MACRO_REPLACEMENTS.each do |name, replacement|
        s.gsub!(/(?<!::)\b#{name}\b/, replacement)
      end
      s
    end

    MACRO_REPLACEMENTS = [
      ['HAND'      , "@player.hand_for(@game)"          ],
      ['OTHERS'    , "@game.other_players_than(@player)"],
      ['BOARDS'    , "@player.boards_for(@game)"        ],
      ['RES_COUNTS', "@player.resource_counts(@game)"   ],
      ['AC_CARDS'  , "@player.active_cards(@game)"      ],
      ['AC_COLORS' , "@player.active_colors(@game)"     ],
      ['INFLUENCE' , "@player.influence_for(@game)"     ],
    ]
end
