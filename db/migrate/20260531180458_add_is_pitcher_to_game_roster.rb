class AddIsPitcherToGameRoster < ActiveRecord::Migration[8.1]
  def change
    add_column :game_rosters, :is_pitcher, :boolean, default: false, null: false
  end
end
