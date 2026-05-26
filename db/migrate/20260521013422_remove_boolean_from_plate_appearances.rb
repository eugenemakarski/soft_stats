class RemoveBooleanFromPlateAppearances < ActiveRecord::Migration[8.1]
  def change
    remove_column :plate_appearances, :boolean, :string
  end
end
