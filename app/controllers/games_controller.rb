class GamesController < ApplicationController
  before_action :set_game, only: %i[show draw]

  # TODO: Move player adding process to a model or a service.
  def index
    if Game.count.zero?
      Game.transaction do
        Game.create!(num_players: 2).tap { |game|
          [
            ['Hmn', false],
            ['Cmp', true ],
          ].each_with_index do |(name, is_computer), index|
            player = Player.create!(name: name, is_computer: is_computer)
            game.playings.create!(player: player, ordering: index)
            player.hands.create!(game: game)
          end
          game.update!(current_player: game.players.first)
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
    @game.current_player.draw_from(stock)

    redirect_to @game
  end

  private

    def set_game
      @game = Game.find(params[:id])
    end
end
