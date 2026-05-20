class TeamsController < ApplicationController
  before_action :set_team, :set_seasons, only: %i[show]

  def index
    @teams = Team.all
  end

  def show
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

  def set_seasons
    @seasons = Season.where(team_id: @team.id)
  end

  def team_params
    params.expect(team: [ :name ])
  end
end
