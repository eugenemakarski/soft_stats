class TeamMembership < ApplicationRecord
  belongs_to :user
  belongs_to :team

  # Integer order is meaningful: anything at or above editor can write.
  enum :role, { viewer: 0, editor: 1, owner: 2 }, prefix: true

  # Used by the "add someone" form, which looks a user up by email rather than
  # taking an id.
  attr_accessor :email_address

  validates :user_id, uniqueness: { scope: :team_id, message: "already has access to this team" }

  scope :editors, -> { where(role: [ :editor, :owner ]) }

  ROLE_LABELS = {
    "viewer" => "Viewer — can see stats and results",
    "editor" => "Editor — can also score games",
    "owner" => "Owner — can also manage members"
  }.freeze

  def self.role_label(role)
    ROLE_LABELS.fetch(role.to_s, role.to_s.humanize)
  end

  def role_label = self.class.role_label(role)

  def can_edit? = role_editor? || role_owner?
end
