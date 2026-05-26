class InningScoresController < ApplicationController
  before_action :set_game

  def new
    @inning = params[:inning].to_i
    @inning_score = InningScore.new(game: @game, inning: @inning, our_half: @game.is_home)
  end

  def create
      inning = inning_score_params[:inning]
      our_half = inning_score_params[:our_half]

    if our_half
      runs = Run.joins(:plate_appearance)
        .where(plate_appearances: { game_id: @game.id, inning: inning })
        .count
    else
      runs = inning_score_params[:runs]
    end

    @inning_score = @game.inning_scores.find_or_initialize_by(
      inning: inning,
      our_half: our_half
    )
    @inning_score.runs = runs

    if @inning_score.save
      redirect_to game_path(@game)
    else
      @inning = @inning_score.inning
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def inning_score_params
    params.expect(inning_score: [ :inning, :our_half, :runs ])
  end
end
