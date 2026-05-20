class SeasonsController < ApplicationController
  before_action :set_season, only: %i[show]
  before_action :set_team, only: %i[create new]
  before_action :set_players, only: %i[show]
  before_action :set_games, only: %i[show]

  def show
  end

  def new
    @season = Season.new
  end

  def create
    @season = Season.new(season_params)
    @season.team_id = @team.id
    if @season.save
      redirect_to team_path(@team)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def set_season
    @season = Season.find(params[:id])
  end
  def set_team
    @team = Team.find(params[:team_id])
  end
  def set_players
    @players = Player.joins(:player_teams).where(player_teams: { season_id: @season.id })
  end
  def set_games
    @games = Game.joins(:season).where.associated(:season)
  end

  def season_params
    params.expect(season: [ :season ])
  end
end
