class PlayerTeam < ApplicationRecord
  belongs_to :player
  belongs_to :team
  belongs_to :season

  has_many :player_positions, dependent: :destroy
  accepts_nested_attributes_for :player_positions, allow_destroy: true, reject_if: :all_blank
end
