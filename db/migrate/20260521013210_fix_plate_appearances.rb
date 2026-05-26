class FixPlateAppearances < ActiveRecord::Migration[8.1]
  def change
    remove_column :plate_appearances, :walk_off, :boolean
    add_column :plate_appearances, :outs_before, :integer, default: 0
    add_column :plate_appearances, :top_inning, :boolean, default: true
  end
end
