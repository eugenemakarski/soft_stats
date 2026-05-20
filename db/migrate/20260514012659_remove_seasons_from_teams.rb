class RemoveSeasonsFromTeams < ActiveRecord::Migration[8.1]
  def change
    remove_column :teams, :seasons, :integer
  end
end
