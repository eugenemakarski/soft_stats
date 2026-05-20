class GameRoster < ApplicationRecord
  belongs_to :game
  belongs_to :player

  validates :batting_order, presence: true, if: -> { available }
  validates :batting_order, absence: true, if: -> { !available }
  validates :batting_order, uniqueness: { scope: :game_id }, allow_nil: true
end
