class TeamsController < ApplicationController
  before_action :set_team, only: %i[show]

  # With a single team there's nothing to choose, so go straight to its games.
  # ?all=1 shows the list anyway (for New Team / Manage Players).
  def index
    @teams = Team.all
    redirect_to team_path(@teams.first) if @teams.one? && params[:all].blank?
  end

  # A team's page is its latest season's games list; this only renders when the
  # team has no seasons yet.
  def show
    latest = @team.latest_season
    redirect_to season_path(latest) if latest
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    if @team.save
      redirect_to teams_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.expect(team: [ :name ])
  end
end
