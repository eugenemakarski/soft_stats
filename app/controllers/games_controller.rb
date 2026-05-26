class GamesController < ApplicationController
  before_action :set_season, only: %i[new create]
  before_action :set_game, only: %i[show start end_half_inning]
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
    @player_options = Player.joins(:player_teams).where(player_teams: { season_id: @game.season_id })
    @rosters = @game.game_rosters.includes(:player)
    @game.inning_scores.load
  end

  def start
    @game.in_progress!
    redirect_to game_path(@game)
  end

  def end_half_inning
    our_top = !@game.is_home
    inning = @game.batting_inning
    our_runs = Run.joins(:plate_appearance)
                  .where(plate_appearances: { game_id: @game.id, inning: inning, top_inning: our_top })
                  .count
    @game.inning_scores.find_or_create_by!(inning: inning, top_inning: our_top) do |s|
      s.runs = our_runs
    end
    redirect_to new_game_inning_score_path(@game, inning: inning)
  end

  private
  def set_season
    @season = Season.find(params[:season_id])
  end

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.expect(game: [ :date, :opponent ])
  end
end
