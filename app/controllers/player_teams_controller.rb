class PlayerTeamsController < ApplicationController
  before_action :set_season, only: %i[index create]
  before_action :set_roster, only: %i[index create destroy]

  def index
    @players = Player.includes(player_teams: :player_positions).where(active: true)
  end

  def show
    @roster = PlayerTeam.includes(:player_positions).find(params[:id])
    @roster.player_positions.build if @roster.player_positions.empty?
  end

  def update
    @roster = PlayerTeam.find(params[:id])
    if @roster.update(player_team_params)
      redirect_to player_team_path(@roster), notice: "Positions saved"
    else
      render :show, status: :unprocessable_entity
    end
  end

  def create
    PlayerTeam.find_or_create_by(player_id: params[:player_id], season_id: @season.id, team_id: @season.team_id)
    redirect_to new_season_player_team_path(@season)
  end

  def destroy
    player_team = PlayerTeam.find(params[:id])
    player_team.destroy
    redirect_back fallback_location: season_path(player_team.season_id)
  end

  private

  def set_season
    @season = Season.find(params[:season_id])
  end

  def set_roster
    @roster = PlayerTeam.where(season_id: params[:season_id])
  end

  def player_team_params
    params.require(:player_team).permit(
      player_positions_attributes: [ :id, :position, :cost, :_destroy ]
    )
  end
end
