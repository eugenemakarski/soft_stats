class PlayersController < ApplicationController
  before_action :set_player, only: %i[show update edit destroy]

  def index
    @players = Player.all
  end

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)
    if @player.save
      redirect_to players_path
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

  def player_params
    params.expect(player: [ :name, :jersey_number, :active ])
  end
end
