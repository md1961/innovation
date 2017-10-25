module PlayerAction

class Offer < Base

  def initialize(game, card, dest)
    super(game, nil)
    @card = card
    @dest = dest
  end

  # TODO: Implement to offer to other than next_player.
  def perform
    prepare_undo_statement_for_card_move(@card)

    card_list_from = @card.card_list(@game)
    player_from = card_list_from.player

    player_to = @game.next_player(player_from)
    card_list_to = dest_to_card_list(player_to)

    ActiveRecord::Base.transaction do
      card_list_from.remove(@card)
      card_list_to.add(@card)
    end
    @card
  end

  def to_s
    "Offer#{@card}-#{@dest}"
  end

  private

    def dest_to_card_list(player)
      if @dest == Hand
        player.hand_for(@game)
      elsif @dest == Board
        player.boards_for(@game).find_by(color: @card.color)
      elsif @dest == Influence
        player.influence_for(@game)
      else
        raise "Illegal destination '#{@dest}'"
      end
    end
end

end
