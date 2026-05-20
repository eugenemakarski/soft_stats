class RemovePlayerIdFromSeasons < ActiveRecord::Migration[8.1]
  def change
    remove_column :seasons, :player_id, :integer
  end
end
