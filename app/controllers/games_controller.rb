class GamesController < ApplicationController
  before_action :set_game            , except: %i[index new]
  before_action :set_action_info     , except: %i[index]
  before_action :clear_undo_statement, except: %i[index show undo]
  before_action :clear_action_options, except: %i[index show]

  KEY_FOR_ACTION_INFO = :action_info

  def index
    redirect_to new_game_path if Game.count.zero?
    @games = Game.all
  end

  def show
    @game_evaluator = GameEvaluator.new(@game, @game.current_player)
  end

  # TODO: Move player adding process to a model or a service.
  def new
    Game.transaction do
      Game.create!(num_players: 2).tap { |game|
        game.invite(Player.find_by(name: 'Hmn'))
        game.invite(Player.find_by(name: 'Cm1'))
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
    perform_action(action)
    redirect_to @game
  end

  def play
    card = Card.find(params[:card_id])
    player = card.card_list(@game).player
    action = PlayerAction::Play.new(@game, player, card)
    perform_action(action)
    redirect_to @game
  end

  def reuse
    card = Card.find(params[:card_id])
    player = card.card_list(@game).player
    action = PlayerAction::Reuse.new(@game, player, card)
    perform_action(action)
    redirect_to @game
  end

  def offer
    card = Card.find(params[:card_id])
    dest = params[:dest].constantize
    action = PlayerAction::Offer.new(@game, card, dest)
    perform_action(action)
    redirect_to @game
  end

  def score
    card = Card.find(params[:card_id])
    player = card.card_list(@game).player
    action = PlayerAction::Score.new(@game, player, card)
    perform_action(action)
    redirect_to @game
  end

  def store
    card = Card.find(params[:card_id])
    player = card.card_list(@game).player
    action = PlayerAction::Store.new(@game, player, card)
    perform_action(action)
    redirect_to @game
  end

  def conquer
    target = params[:target_type].constantize.find(params[:target_id])
    action = PlayerAction::Conquer.new(@game, @game.current_player, target)
    perform_action(action)
    redirect_to @game
  end

  def do_execute

  end

  def test
    ge = GameEvaluator.new(@game, @game.current_player)
    actions = []
    action_sequence = PlayerAction::Sequence.new(ge, actions)
  end

  def end_action
    action = nil
    if @game.uses_ai && @game.turn_player.is_computer && @game.num_actions_left > 0
      player = @game.turn_player
      action = player.choose_action(@game)
      perform_action(action, player.action_options)
    end
    @game.end_action unless action&.conquer_category?
    redirect_to @game
  end

  def undo
    instance_eval(@action_info.undo_statement)
    clear_undo_statement
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

    def set_action_info
      @action_info = ActionInfo.new(session[KEY_FOR_ACTION_INFO])
      clear_action_info(:is_executing, :action_targets, :action_message)
    end

    def perform_action(action, action_options = nil)
      targets = action.perform
      session[KEY_FOR_ACTION_INFO] = ActionInfo.new.tap { |ai|
        ai.is_executing = action.execute?
        ai.action_targets = targets
        ai.action_options = action_options
        ai.action_message = action.message_after
        ai.undo_statement = action.undo_statement
      }
    end

    def clear_undo_statement
      clear_action_info(:undo_statement)
    end

    def clear_action_options
      clear_action_info(:action_options)
    end

    def clear_action_info(*attr_names)
      session[KEY_FOR_ACTION_INFO] = @action_info.dup_cleared(*attr_names)
    end
end
