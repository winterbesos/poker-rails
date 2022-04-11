class BoardGamesController < ApplicationController

  def index
    games = BoardGame.all

    render json: games
  end

end
