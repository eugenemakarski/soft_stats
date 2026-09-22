class GamesController < ApplicationController
  before_action :set_season, only: %i[new create]
  before_action :set_game, only: %i[show start generate_lineup]
  before_action :require_season_edit!, only: %i[new create]
  before_action :require_game_edit!, only: %i[start generate_lineup]

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
    @rosters = @game.game_rosters.includes(:player).where(available: true)
    @game.inning_scores.load
    @fielding = @game.fielding_positions.where(player_id: @rosters.map(&:player_id)).includes(:player)
  end

  def start
    @game.in_progress!
    redirect_to game_path(@game)
  end

  def generate_lineup
    schedule = FieldingLineupGenerator.new(@game).generate_and_save

    if schedule.any? { |inning| inning[:assignments].any? }
      redirect_to game_path(@game), notice: "Fielding lineup generated"
    else
      redirect_to game_path(@game), alert: "No available fielders — set the game roster first."
    end
  end

  private
  def set_season
    @season = Season.visible_to(current_user).find(params[:season_id])
  end

  # Shallow route: /games/:id — nothing above this id proves anything.
  def set_game
    @game = Game.visible_to(current_user).find(params[:id])
    switch_to_team(@game.season.team)
  end

  def require_season_edit!
    require_edit!(@season.team)
  end

  def require_game_edit!
    require_edit!(@game.season.team)
  end

  def game_params
    params.expect(game: [ :date, :opponent, :is_home, :game_type ])
  end
end
