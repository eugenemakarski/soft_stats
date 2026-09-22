class Team < ApplicationRecord
  has_many :seasons
  has_many :player_teams
  has_many :players
  has_many :team_memberships, dependent: :destroy
  has_many :users, through: :team_memberships

  validates :name, presence: true

  # Teams a user has been given access to, at any role.
  scope :visible_to, ->(user) {
    joins(:team_memberships).where(team_memberships: { user_id: user.id })
  }

  def latest_season
    seasons.newest_first.first
  end
end
