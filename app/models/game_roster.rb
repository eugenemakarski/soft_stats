class GameRoster < ApplicationRecord
  belongs_to :game
  belongs_to :player

  validates :batting_order, presence: true, if: -> { available }
  validates :batting_order, absence: true, if: -> { !available }
  validates :batting_order, uniqueness: { scope: :game_id }, allow_nil: true
  validate :exactly_one_pitcher

  default_scope { order(:batting_order) }
end

def exactly_one_pitcher
  count = game.game_rosters.where(is_pitcher: true).where.not(id: id).count
  count += 1 if is_pitcher?
  errors.add(:base, "game must have exactly one pitcher") unless count == 1
end
