namespace :users do
  desc "Create or update a login. USAGE: bin/rails users:create EMAIL=me@example.com PASSWORD=secret [TEAM='Team Name'] [ROLE=owner]"
  task create: :environment do
    email = ENV.fetch("EMAIL")
    password = ENV["PASSWORD"]

    user = User.find_or_initialize_by(email_address: email)

    if user.new_record?
      raise "PASSWORD is required to create #{email}" if password.blank?
      user.password = password
      user.save!
      puts "created user #{user.email_address}"
    else
      user.update!(password: password) if password.present?
      puts "found user #{user.email_address}#{' (password updated)' if password.present?}"
    end

    team_name = ENV["TEAM"].presence
    next if team_name.nil?

    team = Team.find_or_create_by!(name: team_name)
    role = ENV.fetch("ROLE", "owner")
    membership = TeamMembership.find_or_initialize_by(user: user, team: team)
    membership.role = role
    membership.save!
    puts "#{user.email_address} is #{membership.role} of #{team.name}"
  end

  desc "List users and their team access"
  task list: :environment do
    User.includes(team_memberships: :team).order(:email_address).each do |user|
      access = user.team_memberships.map { |m| "#{m.team.name} (#{m.role})" }
      puts "#{user.email_address}: #{access.any? ? access.join(', ') : 'no teams'}"
    end
  end
end
