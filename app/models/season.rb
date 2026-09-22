class Season < ApplicationRecord
  belongs_to :team

  has_many :games
  has_many :player_teams
  has_many :players, through: :player_teams

  scope :newest_first, -> { order(season: :desc, id: :desc) }
  scope :visible_to, ->(user) {
    joins(team: :team_memberships).where(team_memberships: { user_id: user.id })
  }

  def to_s = season.to_s

  # W-L-T over already-loaded games (pass them in so the list page doesn't
  # query twice). Unscored games are skipped.
  def self.record(games)
    outcomes = games.filter_map(&:outcome)
    { wins: outcomes.count(:win), losses: outcomes.count(:loss), ties: outcomes.count(:tie) }
  end

  def record(games)
    self.class.record(games.select(&:game_type_regular?))
  end
end
