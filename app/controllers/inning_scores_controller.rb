class InningScoresController < ApplicationController
  before_action :set_game
  before_action :set_inning, only: %i[new create]

  def new
    @inning_score = InningScore.new(game: @game, inning: @inning, our_half: false)
  end

  def create
      inning = inning_score_params[:inning]
      our_half = ActiveModel::Type::Boolean.new.cast(inning_score_params[:our_half])

    if our_half
      puts "OUR HALF"
      runs = Run.joins(:plate_appearance)
        .where(plate_appearances: { game_id: @game.id, inning: inning })
        .count
    else
      puts "NOT OUR HALF"
      runs = inning_score_params[:runs]
    end

    puts "RUNS:"
    puts "RUNS: #{runs.inspect}"
    puts "PARAMS: #{inning_score_params[:runs].inspect}"


    @inning_score = @game.inning_scores.find_or_initialize_by(
      inning: inning,
      our_half: our_half,
      runs: runs
    )

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

  def set_inning
    @inning = (@game.inning_scores.where(our_half: false).maximum(:inning) || 0) + 1
  end

  def inning_score_params
    params.expect(inning_score: [ :inning, :our_half, :runs ])
  end
end
