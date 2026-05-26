class RemoveColumnsFromPlateAppearances < ActiveRecord::Migration[8.1]
  def change
    remove_column :plate_appearances, :double_play, :boolean
    remove_column :plate_appearances, :walk_off, :boolean
  end
end
