class TeamsController < ApplicationController
  before_action :set_team, only: %i[show]

  # With a single team there's nothing to choose, so go straight to its games.
  # ?all=1 shows the list anyway (for New Team / switching).
  def index
    @teams = current_teams
    redirect_to team_path(@teams.first) if @teams.one? && params[:all].blank?
  end

  # A team's page is its latest season's games list; this only renders when the
  # team has no seasons yet. Visiting it also selects the team.
  def show
    switch_to_team(@team)
    latest = @team.latest_season
    redirect_to season_path(latest) if latest
  end

  def new
    @team = Team.new
  end

  # The creator becomes the owner — without the membership they'd 404 on the
  # team they just made.
  def create
    @team = Team.new(team_params)

    Team.transaction do
      if @team.save
        @team.team_memberships.create!(user: current_user, role: :owner)
        switch_to_team(@team)
        redirect_to team_path(@team)
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  private
  def set_team
    @team = Team.visible_to(current_user).find(params[:id])
  end

  def team_params
    params.expect(team: [ :name ])
  end
end
