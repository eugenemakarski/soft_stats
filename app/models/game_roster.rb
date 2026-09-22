class GameRoster < ApplicationRecord
  belongs_to :game
  belongs_to :player

  validates :batting_order, presence: true, if: -> { available }
  validates :batting_order, absence: true, if: -> { !available }
  validates :batting_order, uniqueness: { scope: :game_id }, allow_nil: true

  default_scope { order(:batting_order) }

  scope :visible_to, ->(user) {
    joins(game: { season: { team: :team_memberships } })
      .where(team_memberships: { user_id: user.id })
  }

  validate :player_must_belong_to_games_team

  private

  def player_must_belong_to_games_team
    team_id = game&.season&.team_id
    return if player.nil? || team_id.nil?

    errors.add(:player, "is not on this team") unless player.team_id == team_id
  end
end
