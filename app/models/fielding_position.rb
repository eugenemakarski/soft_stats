class FieldingPosition < ApplicationRecord
  belongs_to :game
  belongs_to :player

  include PositionEnum
end
