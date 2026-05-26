class CreateRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :runs do |t|
      t.references :plate_appearance, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true

      t.timestamps
    end
  end
end
