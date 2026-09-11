class GameRostersController < ApplicationController
  before_action :set_game
  before_action :set_player_options

  def index
    @existing_rosters = @game.game_rosters.includes(:player).where(available: true)
    @pitcher_roster = @game.game_rosters.find_by(is_pitcher: true)
  end

  def create
    player_ids = Array(params.dig(:lineup, :player_ids)).reject(&:blank?)
    pitcher_id = params[:pitcher_id].presence

    if pitcher_id.blank?
      flash[:alert] = "Game must have exactly 1 pitcher"
      redirect_to game_game_rosters_path(@game) and return
    end

    batting_orders = player_ids.each_with_index.to_h { |id, index| [ id, index + 1 ] }

    rosters = @player_options.map do |player|
      roster = GameRoster.find_or_initialize_by(game_id: @game.id, player_id: player.id)
      order = batting_orders[player.id.to_s]
      roster.available = order.present?
      roster.batting_order = order
      roster.is_pitcher = (player.id.to_s == pitcher_id)
      roster
    end

    if rosters.all?(&:valid?)
      rosters.each(&:save)
      redirect_to game_path(@game)
    else
      flash[:alert] = rosters.flat_map { |r| r.errors.full_messages }.uniq.join(", ")
      redirect_to game_game_rosters_path(@game)
    end
  end

  private
  def set_game
    @game = Game.find(params[:game_id])
  end

  def set_player_options
    @player_options = Player.joins(:player_teams)
                             .where(player_teams: { season_id: @game.season_id })
                             .distinct
                             .order(:name)
  end
end
