class CardsController < ApplicationController

  def index
    @cards = Card.all
  end

  def show
    @card = Card.find(params[:id])
    @game = Game.last
  end
end
