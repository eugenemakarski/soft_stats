class RemoveRunFromPlateAppearances < ActiveRecord::Migration[8.1]
  def change
    remove_column :plate_appearances, :run, :boolean
  end
end
