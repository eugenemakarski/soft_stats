class CreateGameRosters < ActiveRecord::Migration[8.1]
  def change
    create_table :game_rosters do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.integer :batting_order
      t.boolean :available

      t.timestamps
    end
  end
end
