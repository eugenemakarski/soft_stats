class AddTeamToPlayers < ActiveRecord::Migration[8.1]
  def change
    # Nullable for now; backfilled by the next migration and tightened to
    # null: false once the data is confirmed clean.
    add_reference :players, :team, foreign_key: true
  end
end
