class AddColumnsToPlayers < ActiveRecord::Migration[8.1]
  def change
    add_column :players, :jersey_number, :integer
    add_column :players, :active, :boolean
  end
end
