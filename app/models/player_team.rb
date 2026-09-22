class PlayerTeam < ApplicationRecord
  belongs_to :player
  belongs_to :team
  belongs_to :season

  has_many :player_positions, dependent: :destroy
  accepts_nested_attributes_for :player_positions, allow_destroy: true, reject_if: :all_blank

  scope :visible_to, ->(user) {
    joins(team: :team_memberships).where(team_memberships: { user_id: user.id })
  }

  # player_id arrives as raw params in places; this is the backstop that keeps
  # a roster row from ever pointing at another team's player.
  validate :player_must_belong_to_team

  private

  def player_must_belong_to_team
    return if player.nil? || team_id.nil?

    errors.add(:player, "is not on this team") unless player.team_id == team_id
  end
end
