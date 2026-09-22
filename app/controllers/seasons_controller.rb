class SeasonsController < ApplicationController
  before_action :set_season, only: %i[show stats]
  before_action :set_team, only: %i[create new]
  before_action :require_team_edit!, only: %i[new create]

  # The games list, newest first — the landing page for a team.
  def show
    @seasons = @season.team.seasons.newest_first
    @games = @season.games.newest_first.includes(:inning_scores).to_a
    @record = @season.record(@games)
    @playoff_record = Season.record(@games.select(&:game_type_playoff?))
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

  def stats
    @game_type = requested_game_type
    @games = @season.games.of_type(@game_type).chronological
    @players = @season.players.distinct.order(:name)

    plate_appearances = PlateAppearance.where(game_id: @games.select(:id))
    @batting_stats = PlayerSeasonStats.for(players: @players, plate_appearances: plate_appearances)
    @pitching_stats = PlayerPitchingStats.for(games: @games)
  end


  private
  # Shallow route: /seasons/:id — the scope is the only thing between a foreign
  # id and this team's data.
  def set_season
    @season = Season.visible_to(current_user).find(params[:id])
    switch_to_team(@season.team)
  end

  def set_team
    @team = Team.visible_to(current_user).find(params[:team_id])
  end

  def require_team_edit!
    require_edit!(@team)
  end

  def requested_game_type
    type = params[:game_type].presence
    type if type && Game.game_types.key?(type)
  end

  def season_params
    params.expect(season: [ :season ])
  end
end
