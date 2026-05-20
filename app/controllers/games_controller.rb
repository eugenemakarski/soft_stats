class GamesController < ApplicationController
  before_action :set_season, only: %i[new create]
  def new
    @game = Game.new
  end

  def create
    @game = Game.new(game_params)
    @game.season_id = @season.id
    if @game.save
      redirect_to game_path(@game.id)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @game = Game.find(params[:id])
    @player_options = Player.joins(:player_teams).where(player_teams: { season_id: @game.season_id })
    @rosters = @game.game_rosters.includes(:player)
  end

  def start
    @game.in_progress!
    redirect_to game_path(@game)
  end

  private
  def set_season
    @season = Season.find(params[:season_id])
  end

  def game_params
    params.expect(game: [ :date, :opponent ])
  end
end
