class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def membership_for(team)
    return nil if team.nil?

    team_memberships.find_by(team_id: team.is_a?(Team) ? team.id : team)
  end

  def can_edit?(team) = !!membership_for(team)&.can_edit?

  def owns?(team) = !!membership_for(team)&.role_owner?
end
