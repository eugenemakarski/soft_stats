class PlayerTeamsController < ApplicationController
  before_action :set_season, only: %i[index create]
  before_action :set_roster

  def index
    @players = Player.where(active: true)
  end

  def show
  end

  def create
    PlayerTeam.find_or_create_by(player_id: params[:player_id], season_id: @season.id, team_id: @season.team_id)
    redirect new_season_player_team_path(@season)
  end

  def destroy
    player_team = PlayerTeam.find(params[:id])
    player_team.destroy
    redirect_back fallback_location: season_path(player_team.season_id)
  end

  def set_season
    @season = Season.find(params[:season_id])
  end

  def set_roster
    @roster = PlayerTeam.where(season_id: params[:season_id])
  end
end
