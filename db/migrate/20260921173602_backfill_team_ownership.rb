class BackfillTeamOwnership < ActiveRecord::Migration[8.1]
  # Gives every existing team an owner, and every existing player a team.
  # Re-runnable: both halves skip rows that are already assigned.
  def up
    backfill_owner_memberships
    backfill_player_teams
  end

  def down
    # Irreversible in the sense that we can't know which memberships predated
    # the backfill, but dropping the tables/columns is handled by the other
    # migrations, so there's nothing to undo here.
  end

  private

  def backfill_owner_memberships
    teams = select_all("SELECT id FROM teams").rows.flatten
    return if teams.empty?

    owner_id = owner_user_id
    now = quote(Time.current)

    teams.each do |team_id|
      existing = select_value(
        "SELECT COUNT(*) FROM team_memberships WHERE team_id = #{team_id.to_i}"
      )
      next if existing.to_i.positive?

      execute <<~SQL
        INSERT INTO team_memberships (user_id, team_id, role, created_at, updated_at)
        VALUES (#{owner_id.to_i}, #{team_id.to_i}, 2, #{now}, #{now})
      SQL
    end
  end

  def backfill_player_teams
    # A player's team comes from their roster rows. More than one distinct team
    # means the player would have to be split into per-team records — stop and
    # say so rather than guessing.
    conflicted = select_all(<<~SQL).rows
      SELECT p.id, p.name
      FROM players p
      JOIN player_teams pt ON pt.player_id = p.id
      WHERE p.team_id IS NULL
      GROUP BY p.id, p.name
      HAVING COUNT(DISTINCT pt.team_id) > 1
    SQL

    if conflicted.any?
      names = conflicted.map { |id, name| "#{name} (##{id})" }.join(", ")
      raise ActiveRecord::MigrationError,
        "These players are rostered on more than one team and must be split " \
        "into one record per team before this migration can run: #{names}"
    end

    execute <<~SQL
      UPDATE players
      SET team_id = (
        SELECT pt.team_id FROM player_teams pt WHERE pt.player_id = players.id LIMIT 1
      )
      WHERE team_id IS NULL
        AND EXISTS (SELECT 1 FROM player_teams pt WHERE pt.player_id = players.id)
    SQL

    backfill_orphan_players
  end

  # Players that were never rostered have no team to infer. With exactly one
  # team in the database the answer is unambiguous; otherwise leave them null
  # and report, so AddNotNullToPlayersTeam fails loudly rather than silently
  # attaching them to the wrong team.
  def backfill_orphan_players
    orphans = select_value("SELECT COUNT(*) FROM players WHERE team_id IS NULL").to_i
    return if orphans.zero?

    team_ids = select_all("SELECT id FROM teams").rows.flatten
    if team_ids.one?
      execute "UPDATE players SET team_id = #{team_ids.first.to_i} WHERE team_id IS NULL"
    else
      say "#{orphans} player(s) have no roster rows and could not be assigned a team; " \
          "set players.team_id manually before running AddNotNullToPlayersTeam.", true
    end
  end

  def owner_user_id
    email = ENV["OWNER_EMAIL"].presence
    id =
      if email
        select_value("SELECT id FROM users WHERE email_address = #{quote(email.strip.downcase)}")
      else
        select_value("SELECT id FROM users ORDER BY id LIMIT 1")
      end

    return id if id

    raise ActiveRecord::MigrationError,
      "No user to own existing teams. Create one first (bin/rails users:create " \
      "EMAIL=you@example.com PASSWORD=...) and re-run, optionally with OWNER_EMAIL set."
  end
end
