class AddGameTypeToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :game_type, :integer, default: 0, null: false
    add_index :games, [ :season_id, :game_type ]
  end
end
