class GamesController < ApplicationController
  before_action :set_game, except: %i[index]

  # TODO: Move player adding process to a model or a service.
  def index
    if Game.count.zero?
      Game.transaction do
        Game.create!(num_players: 2).tap { |game|
          game.invite(Player.find_by(name: 'Hmn'))
          game.invite(Player.find_by(name: 'Cm1'))
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

  def play
    card = Card.find(params[:card_id])
    @game.current_player.play(card, @game)
    redirect_to @game
  end

  def reuse
    card = Card.find(params[:card_id])
    card.reuse(@game)
    redirect_to @game
  end

  def end_turn
    @game.end_turn
    redirect_to @game
  end

  private

    def set_game
      if Game.exists?(params[:id])
        @game = Game.find(params[:id])
      else
        redirect_to games_path
      end
    end
end
