class Run < ApplicationRecord
  belongs_to :plate_appearance
  belongs_to :player

  scope :visible_to, ->(user) {
    joins(plate_appearance: { game: { season: { team: :team_memberships } } })
      .where(team_memberships: { user_id: user.id })
  }

  # run_scorer_ids arrives as raw params, so verify the scorer is on the team
  # whose game this run belongs to.
  validate :player_must_belong_to_games_team

  private

  def player_must_belong_to_games_team
    team_id = plate_appearance&.game&.season&.team_id
    return if player.nil? || team_id.nil?

    errors.add(:player, "is not on this team") unless player.team_id == team_id
  end
end
