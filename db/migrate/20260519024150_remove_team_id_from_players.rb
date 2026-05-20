class RemoveTeamIdFromPlayers < ActiveRecord::Migration[8.1]
  def change
    remove_column :players, :team_id, :integer
  end
end
