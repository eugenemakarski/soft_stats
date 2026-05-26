class PlateAppearancesController < ApplicationController
  before_action :set_game

  ON_BASE_RESULTS = %w[single double triple walk hbp fielders_choice error].freeze

  def new
    @plate_appearance = PlateAppearance.new(
      game: @game,
      inning: params[:inning],
      top_inning: params[:top_inning],
      player_id: params[:player_id]
    )
    @on_base_players = on_base_players(params[:inning], params[:top_inning])
  end

  def create
    @plate_appearance = PlateAppearance.new(plate_appearance_params)
    @plate_appearance.game = @game

    scorer_ids = Array(params[:run_scorer_ids])
    rbi_count = @plate_appearance.rbi.to_i
    home_run = @plate_appearance.result == "home_run"
    expected_scorers = home_run ? rbi_count - 1 : rbi_count

    if rbi_count > 0 && scorer_ids.length != expected_scorers
      @plate_appearance.errors.add(:rbi, "is #{rbi_count} but #{scorer_ids.length} runner(s) were selected")
      @on_base_players = on_base_players(params[:plate_appearance][:inning], params[:plate_appearance][:top_inning])
      render :new, status: :unprocessable_entity and return
    end

    if @plate_appearance.save
      Run.create!(plate_appearance: @plate_appearance, player_id: @plate_appearance.player_id) if home_run
      mark_runners_scored(scorer_ids) if scorer_ids.any?
      redirect_to game_path(@game)
    else
      @on_base_players = on_base_players(params[:plate_appearance][:inning], params[:plate_appearance][:top_inning])
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end



  def plate_appearance_params
    params.expect(plate_appearance: [ :player_id, :inning, :top_inning, :result, :rbi, :outs_before ])
  end

  def on_base_players(inning, top_inning)
    top = ActiveRecord::Type::Boolean.new.cast(top_inning)
    scored_player_ids = Run.joins(:plate_appearance)
                           .where(plate_appearances: { game_id: @game.id, inning: inning, top_inning: top })
                           .pluck(:player_id)

    @game.plate_appearances
         .where(inning: inning, top_inning: top)
         .where(result: ON_BASE_RESULTS.map { |r| PlateAppearance.results[r] })
         .where.not(player_id: scored_player_ids)
         .includes(:player)
         .map(&:player)
         .uniq
  end

  def mark_runners_scored(player_ids)
    player_ids.each do |player_id|
      pa = @game.plate_appearances
                .where(player_id: player_id,
                       inning: @plate_appearance.inning,
                       top_inning: @plate_appearance.top_inning)
                .where(result: ON_BASE_RESULTS.map { |r| PlateAppearance.results[r] })
                .order(:created_at)
                .last
      Run.create!(plate_appearance: pa, player_id: player_id) if pa
    end
  end
end
