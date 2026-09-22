class PlayersController < ApplicationController
  before_action :set_team, only: %i[index new create]
  before_action :set_player, only: %i[show update edit destroy]
  before_action :require_team_edit!, only: %i[new create]

  def index
    @players = @team.players.order(:name)
  end

  def new
    @player = @team.players.new
  end

  def create
    # team_id is never mass-assignable — it comes from the URL, not the form.
    @player = @team.players.new(player_params)
    if @player.save
      redirect_to team_players_path(@team)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @player.update(player_params)
      redirect_to team_players_path(@player.team)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    team = @player.team
    if @player.destroy
      redirect_to team_players_path(team)
    else
      redirect_to team_players_path(team), alert: @player.errors.full_messages.to_sentence
    end
  end

  private
  def set_team
    @team = Team.visible_to(current_user).find(params[:team_id])
    switch_to_team(@team)
  end

  # Shallow route: /players/:id
  def set_player
    @player = Player.visible_to(current_user).find(params[:id])
    switch_to_team(@player.team)
    require_edit!(@player.team) unless action_name == "show"
  end

  def require_team_edit!
    require_edit!(@team)
  end

  def player_params
    params.expect(player: [ :name, :jersey_number, :active ])
  end
end
