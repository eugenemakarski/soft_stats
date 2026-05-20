class Player < ApplicationRecord
  validates :name, presence: true
  has_many :player_teams
  has_many :teams, through: :player_teams
  has_many :seasons, through: :player_teams
end
