class PlayerPosition < ApplicationRecord
  belongs_to :player_team

  include PositionEnum
end
