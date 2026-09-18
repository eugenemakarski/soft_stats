class Team < ApplicationRecord
  has_many :seasons
  has_many :player_teams
  validates :name, presence: true

  def latest_season
    seasons.newest_first.first
  end
end
