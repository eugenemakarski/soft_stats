class PlayersController < ApplicationController
  before_action :set_season, only: %i[index new create]
  before_action :set_player, only: %i[show edit update destroy]

  def index
    @players = Player.joins(:player_teams).where(player_teams: { season_id: @season.id })
  end

  def show
    @playerSeason = @player.player_teams.first.season
  end

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)
    if @player.save
      @playerTeam = PlayerTeam.create!(
        player: @player,
        team_id: @season.team_id,
        season: @season
      )
      redirect_to season_path(@season.id)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @player.update(player_params)
      redirect_to players_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @player.destroy
    redirect_to players_path
  end

  private
  def set_player
    @player = Player.find(params[:id])
  end

  def set_season
    @season = Season.find(params[:season_id])
  end

  def player_params
    params.expect(player: [ :name, :jersey_number, :active ])
  end
end
