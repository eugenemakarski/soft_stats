class AddNotNullToPlayersTeam < ActiveRecord::Migration[8.1]
  def up
    orphans = select_value("SELECT COUNT(*) FROM players WHERE team_id IS NULL").to_i
    if orphans.positive?
      raise ActiveRecord::MigrationError,
        "#{orphans} player(s) still have no team_id. Assign them a team, then re-run."
    end

    change_column_null :players, :team_id, false
  end

  def down
    change_column_null :players, :team_id, true
  end
end
