class PlayerTeam < ApplicationRecord
  belongs_to :player
  belongs_to :team
  belongs_to :season
end
