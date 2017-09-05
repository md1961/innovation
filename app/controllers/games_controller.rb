class GamesController < ApplicationController

  def index
    if Game.count.zero?
      Game.create!(num_players: 2).tap { |game|
        game.players.create!(name: 'Hmn', is_computer: false)
        game.players.create!(name: 'Cmp', is_computer: true )
      }
    end
    redirect_to Game.order(:created_at).last
  end

  def show
    @game = Game.find(params[:id])
  end
end
