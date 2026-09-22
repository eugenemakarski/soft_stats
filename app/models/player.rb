class Player < ApplicationRecord
  belongs_to :team

  validates :name, presence: true
  has_many :player_teams
  has_many :seasons, through: :player_teams

  scope :visible_to, ->(user) {
    joins(team: :team_memberships).where(team_memberships: { user_id: user.id })
  }
end
