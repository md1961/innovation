class GamesController < ApplicationController

  def index
    if Game.count.zero?
      Game.transaction do
        Game.create!(num_players: 2).tap { |game|
          player0 = Player.create!(name: 'Hmn', is_computer: false)
          player1 = Player.create!(name: 'Cmp', is_computer: true )
          game.playings.create!(player: player0, ordering: 0)
          game.playings.create!(player: player1, ordering: 1)
          game.update!(current_player: player0)
        }
      end
    end
    redirect_to Game.order(:created_at).last
  end

  def show
    @game = Game.find(params[:id])
  end
end
