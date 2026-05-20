class CreatePlateAppearances < ActiveRecord::Migration[8.1]
  def change
    create_table :plate_appearances do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.integer :inning
      t.integer :result
      t.integer :rbi
      t.boolean :run
      t.boolean :walk_off
      t.string :double_play
      t.string :boolean

      t.timestamps
    end
  end
end
