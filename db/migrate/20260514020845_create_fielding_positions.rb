class CreateFieldingPositions < ActiveRecord::Migration[8.1]
  def change
    create_table :fielding_positions do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :inning
      t.references :player, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
