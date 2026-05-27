class PlayerTeam < ApplicationRecord
  belongs_to :player
  belongs_to :team
  belongs_to :season

  has_many :player_position
end
