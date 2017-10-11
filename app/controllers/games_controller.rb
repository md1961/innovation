class GamesController < ApplicationController
  before_action :set_game  , except: %i[index new]
  before_action :clear_undo, except: %i[index show undo]
  before_action :clear_info, except: %i[index show]

  KEY_FOR_UNDO_STATEMENT = :undo_statement
  KEY_FOR_ACTION_OPTIONS = :action_options

  def index
    redirect_to new_game_path if Game.count.zero?
    @games = Game.all
  end

  def show
    @game_evaluator = GameEvaluator.new(@game, @game.current_player)
    @game.undo_statement = session[KEY_FOR_UNDO_STATEMENT]
    @game.action_options = session[KEY_FOR_ACTION_OPTIONS]
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
    action = PlayerAction::Draw.new(@game, @game.current_player, age)
    action.perform
    save_undo_statement(action.undo_statement)
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
    dest = params[:dest].constantize
    card.offer(dest, @game)
    redirect_to @game
  end

  def score
    card = Card.find(params[:card_id])
    player = card.card_list(@game).player
    action = PlayerAction::Score.new(@game, player, card)
    action.perform
    save_undo_statement(action.undo_statement)
    redirect_to @game
  end

  def store
    card = Card.find(params[:card_id])
    player = card.card_list(@game).player
    action = PlayerAction::Store.new(@game, player, card)
    action.perform
    save_undo_statement(action.undo_statement)
    redirect_to @game
  end

  def conquer
    target = params[:target_type].constantize.find(params[:target_id])
    action = PlayerAction::Conquer.new(@game, @game.current_player, target)
    action.perform
    save_undo_statement(action.undo_statement)
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
      player = @game.turn_player
      action = player.choose_action(@game)
      session[KEY_FOR_ACTION_OPTIONS] = player.action_options
      action.perform
      save_undo_statement(action.undo_statement)
      notice = action.message_after
    end
    @game.end_action unless action&.conquer_category?
    redirect_to @game, notice: notice
  end

  def undo
    instance_eval(session[KEY_FOR_UNDO_STATEMENT])
    clear_undo
    redirect_to @game
  end

  def increment_action
    @game.increment!(:num_actions_left)
  end

  def action_options
    player = @game.turn_player
    player.choose_action(@game)
    @action_options = player.action_options.sub(/\s+<=\s+\d+\z/, '')
  end

  def board_info
    @player = @game.current_player
    @game_evaluator = GameEvaluator.new(@game, @player)
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

    def clear_info
      session[KEY_FOR_ACTION_OPTIONS] = nil
    end
end
