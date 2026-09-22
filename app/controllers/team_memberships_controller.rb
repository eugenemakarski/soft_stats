class TeamMembershipsController < ApplicationController
  before_action :set_team
  before_action :require_team_owner!

  def index
    @memberships = @team.team_memberships.includes(:user).order(:role)
    @membership = TeamMembership.new
  end

  # There's no signup page, so the user has to exist already — create logins
  # with `bin/rails users:create`.
  def create
    user = User.find_by(email_address: membership_params[:email_address].to_s.strip.downcase)

    if user.nil?
      redirect_to team_members_path(@team),
        alert: "No account with that email. Create it first: bin/rails users:create EMAIL=… PASSWORD=…"
      return
    end

    membership = @team.team_memberships.new(user: user, role: membership_params[:role])

    if membership.save
      redirect_to team_members_path(@team), notice: "#{user.email_address} added"
    else
      redirect_to team_members_path(@team), alert: membership.errors.full_messages.to_sentence
    end
  end

  def update
    membership = @team.team_memberships.find(params[:id])

    if last_owner?(membership) && membership_params[:role] != "owner"
      redirect_to team_members_path(@team), alert: "A team needs at least one owner."
      return
    end

    if membership.update(role: membership_params[:role])
      redirect_to team_members_path(@team), notice: "Role updated"
    else
      redirect_to team_members_path(@team), alert: membership.errors.full_messages.to_sentence
    end
  end

  def destroy
    membership = @team.team_memberships.find(params[:id])

    if last_owner?(membership)
      redirect_to team_members_path(@team), alert: "A team needs at least one owner."
      return
    end

    membership.destroy
    redirect_to team_members_path(@team), notice: "Access removed"
  end

  private

  def set_team
    @team = Team.visible_to(current_user).find(params[:team_id])
    switch_to_team(@team)
  end

  def require_team_owner!
    require_owner!(@team)
  end

  def last_owner?(membership)
    membership.role_owner? && @team.team_memberships.where(role: :owner).count == 1
  end

  def membership_params
    params.expect(team_membership: [ :email_address, :role ])
  end
end
