# Team-scoped access — who is allowed to see which records.
#
# The problem: a URL like /games/812 hands us nothing but the number 812, and
# anyone logged in can type a different number. Game.find(812) would happily
# return someone else's game.
#
# So: CHECK ONCE, WHERE THE NUMBER COMES IN FROM THE URL.
#
#   Game.visible_to(current_user).find(params[:id])
#
# visible_to joins through team_memberships, so it only searches games on teams
# this user belongs to. Someone else's id finds nothing, .find raises
# RecordNotFound, and Rails renders a 404 — which looks the same as a game that
# doesn't exist, so it doesn't even confirm the record is there.
#
# AFTER THAT, JUST FOLLOW THE ASSOCIATIONS.
#
#   @game.game_rosters     # can only be that game's rosters
#   @season.team.players   # can only be that team's players
#
# These can't return another team's rows, so don't re-check them — an extra
# visible_to there only makes it look like the check matters in the wrong place.
#
# To audit later (e.g. after adding a controller), list every lookup by id:
#   grep -rnE '\b(Team|Season|Game|Player|PlayerTeam|PlateAppearance|GameRoster|InningScore|FieldingPosition|Run)\.find\(' app/controllers
# Every result should have visible_to in it.
module Tenancy
  extend ActiveSupport::Concern

  included do
    before_action :set_current_team
    helper_method :current_user, :current_team, :current_teams
  end

  private

  def current_user = Current.user

  def current_team = Current.team

  def current_teams
    @current_teams ||= current_user ? current_user.teams.order(:name).to_a : []
  end

  def current_team!
    current_team || raise(ActiveRecord::RecordNotFound, "no team selected")
  end

  # The cookie holds an id, never a grant: membership is re-checked against the
  # database every request, so revoking access takes effect immediately.
  def set_current_team
    return if current_user.nil?

    Current.team =
      Team.visible_to(current_user).find_by(id: session[:team_id]) ||
      (current_teams.one? ? current_teams.first : nil)
  end

  # Called by the finders that resolve a team-owned record, so the nav follows
  # the page you're actually on rather than the last team you clicked.
  def switch_to_team(team)
    return if team.nil? || team.id == Current.team&.id

    session[:team_id] = team.id
    Current.team = team
  end

  def require_edit!(team)
    head :forbidden unless current_user&.can_edit?(team)
  end

  def require_owner!(team)
    head :forbidden unless current_user&.owns?(team)
  end
end
