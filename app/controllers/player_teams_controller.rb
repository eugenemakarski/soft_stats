class PlayerTeamsController < ApplicationController
  before_action :set_season, only: %i[index create]
  before_action :set_roster, only: %i[index create destroy]
  # The roster page is a management UI end to end, so viewers don't get it.
  before_action :require_season_edit!, only: %i[index create]

  def index
    # Was every active player in the database; now only this team's.
    @players = @season.team.players
                      .includes(player_teams: :player_positions)
                      .where(active: true)
                      .order(:name)
  end

  def show
    @roster = PlayerTeam.visible_to(current_user).includes(:player_positions).find(params[:id])
    switch_to_team(@roster.team)
    require_edit!(@roster.team)
    return if performed?

    @roster.player_positions.build if @roster.player_positions.empty?
  end

  def update
    @roster = PlayerTeam.visible_to(current_user).find(params[:id])
    require_edit!(@roster.team)
    return if performed?

    if @roster.update(player_team_params)
      redirect_to player_team_path(@roster), notice: "Positions saved"
    else
      render :show, status: :unprocessable_entity
    end
  end

  def create
    # player_id is raw user input: resolve it through the season's team so a
    # foreign id 404s instead of joining this roster.
    player = @season.team.players.find(params[:player_id])
    PlayerTeam.find_or_create_by!(player_id: player.id, season_id: @season.id, team_id: @season.team_id)
    redirect_to season_player_teams_path(@season)
  end

  def destroy
    player_team = PlayerTeam.visible_to(current_user).find(params[:id])
    require_edit!(player_team.team)
    return if performed?

    season_id = player_team.season_id
    player_team.destroy
    redirect_back fallback_location: season_path(season_id)
  end

  private

  def set_season
    @season = Season.visible_to(current_user).find(params[:season_id])
    switch_to_team(@season.team)
  end

  def set_roster
    @roster = PlayerTeam.where(season_id: @season&.id || params[:season_id])
  end

  def require_season_edit!
    require_edit!(@season.team)
  end

  def player_team_params
    params.require(:player_team).permit(
      player_positions_attributes: [ :id, :position, :cost, :_destroy ]
    )
  end
end
