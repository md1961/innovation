class GamesController < ApplicationController
  before_action :set_game  , except: %i[index new]
  before_action :clear_undo, except: %i[index show]

  KEY_FOR_UNDO_STATEMENT = :undo_statement

  def index
    redirect_to new_game_path if Game.count.zero?
    @games = Game.all
  end

  def show
    @game_evaluator = GameEvaluator.new(@game, @game.current_player)
    @game.undo_statement = session[KEY_FOR_UNDO_STATEMENT]
  end

  # TODO: Move player adding process to a model or a service.
  def new
    Game.transaction do
      Game.create!(num_players: 2).tap { |game|
        game.invite(Player.find_by(name: 'Cm1'))
        game.invite(Player.find_by(name: 'Cm2'))
        player = game.players.first
        game.update!(turn_player: player, current_player: player)
      }
    end
    redirect_to games_path
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
    player = card.card_list(@game).player
    action = PlayerAction::Play.new(@game, player, card)
    action.perform
    save_undo_statement(action.undo_statement)
    redirect_to @game
  end

  def reuse
    card = Card.find(params[:card_id])
    card.reuse(@game)
    redirect_to @game
  end

  def offer
    card = Card.find(params[:card_id])
    card.offer(@game)
    redirect_to @game
  end

  def score
    card = Card.find(params[:card_id])
    player = card.card_list(@game).player
    player.score(card, @game)
    redirect_to @game
  end

  def store
    card = Card.find(params[:card_id])
    player = card.card_list(@game).player
    player.store(card, @game)
    redirect_to @game
  end

  def unexpand
    board = Board.find(params[:board_id])
    board.not_expanded!
    redirect_to @game
  end

  def expand_left
    board = Board.find(params[:board_id])
    board.expanded_left!
    redirect_to @game
  end

  def expand_right
    board = Board.find(params[:board_id])
    board.expanded_right!
    redirect_to @game
  end

  def expand_upward
    board = Board.find(params[:board_id])
    board.expanded_upward!
    redirect_to @game
  end

  def switch_player
    @game.switch_player
    redirect_to @game
  end

  def to_turn_player
    @game.to_turn_player
    redirect_to @game
  end

  def end_action
    notice = nil
    if @game.uses_ai && @game.turn_player.is_computer && @game.num_actions_left > 0
      action = @game.turn_player.choose_action(@game)
      action.perform
      save_undo_statement(action.undo_statement)
      notice = action.message_after
    end
    @game.end_action unless action.conquer_category?
    redirect_to @game, notice: notice
  end

  def increment_action
    @game.increment!(:num_actions_left)
    redirect_to @game
  end

  def conquer
    target = params[:target_type].constantize.find(params[:target_id])
    @game.current_player.conquer(target, @game)
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

    def clear_undo
      session[KEY_FOR_UNDO_STATEMENT] = nil
    end

    def save_undo_statement(statement)
      session[KEY_FOR_UNDO_STATEMENT] = statement
    end
end
