class Current < ActiveSupport::CurrentAttributes
  attribute :session
  # The team the UI is currently "in". Display only — it decides what the nav
  # points at and who owns newly created records. Never use it to authorize a
  # read; that is always visible_to(Current.user) or a proven parent.
  attribute :team
  delegate :user, to: :session, allow_nil: true
end
