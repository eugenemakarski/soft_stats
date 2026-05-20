class GameRostersController < ApplicationController
  before_action :set_game
  before_action :set_player_options
  def index
  end

  def new
    @roster = GameRoster.new
  end

  def create
    rosters = []
    params[:roster].each do |player_id, attrs|
      roster = GameRoster.find_or_initialize_by(game_id: @game.id, player_id: player_id)
      roster.batting_order = attrs[:batting_order].presence
      roster.available = attrs[:available] == "1"
      rosters << roster
    end

    if rosters.all?(&:valid?)
      rosters.each(&:save)
      redirect_to game_path(@game)
    else
      errors = rosters.flat_map { |r| r.errors.full_messages }
      flash[:alert] = errors.join(", ")
      redirect_to game_game_rosters_path(@game)
    end
  end

  private
  def set_game
    @game = Game.find(params[:game_id])
  end

  def set_player_options
    @player_options = Player.joins(:player_teams).where(player_teams: { season_id: @game.season_id })
  end

  def roster_params
    params.expect(roster: [ :player_id, :batting_order, :available ])
  end
end
