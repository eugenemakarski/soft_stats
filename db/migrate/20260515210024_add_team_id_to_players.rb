class AddTeamIdToPlayers < ActiveRecord::Migration[8.1]
  def change
    add_reference :players, :team, null: false, foreign_key: true
  end
end
