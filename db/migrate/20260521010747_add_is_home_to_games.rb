class AddIsHomeToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :is_home, :boolean, null: false, default: false
    change_column_default :games, :is_home, nil
  end
end
