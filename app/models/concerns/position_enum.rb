module PositionEnum
  POSITIONS = {
    "P": 1, "C": 2, "1B": 3, "2B": 4, "3B": 5,
    "SS": 6, "LF": 7, "CF": 8, "RF": 9, "ROVER": 10
  }.freeze

  def self.included(base)
    base.enum :position, POSITIONS
  end
end
