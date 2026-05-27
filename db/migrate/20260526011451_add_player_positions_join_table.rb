class AddPlayerPositionsJoinTable < ActiveRecord::Migration[8.1]
  def change
    create_table :player_positions do |t|
      t.references :player_team
      t.integer :position
      t.integer :cost
    end
  end
end
