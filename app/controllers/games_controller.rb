class GamesController < ApplicationController
  before_action :set_game, only: %i[show draw]

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
  end

  def draw
    age_level = Integer(params[:age_level])
    age = Age.find_by(level: age_level)
    stock = @game.stocks.find_by(age: age)
    Game.transaction do
      card = stock.draw
      @game.current_player.hand.add(card)
    end

    redirect_to @game
  end

  private

    def set_game
      @game = Game.find(params[:id])
    end
end
