# Runs on every container boot via bin/docker-entrypoint, so this must stay
# idempotent and must not blow up when the env vars are absent.
#
# For ad-hoc logins and access, use the rake task instead:
#   bin/rails users:create EMAIL=… PASSWORD=… TEAM='Team Name' ROLE=viewer
#   bin/rails users:list
if ENV["SEED_USER_EMAIL"].present? && ENV["SEED_USER_PASSWORD"].present?
  user = User.find_or_initialize_by(email_address: ENV["SEED_USER_EMAIL"])

  if user.new_record?
    user.password = ENV["SEED_USER_PASSWORD"]
    user.save!
    Rails.logger.info "[seeds] created user #{user.email_address}"
  end

  if ENV["SEED_TEAM_NAME"].present?
    team = Team.find_or_create_by!(name: ENV["SEED_TEAM_NAME"])
    TeamMembership.find_or_create_by!(user: user, team: team) { |m| m.role = :owner }
    Rails.logger.info "[seeds] #{user.email_address} owns #{team.name}"
  end
end
