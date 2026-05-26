class CreateInningScores < ActiveRecord::Migration[8.1]
  def change
    create_table :inning_scores do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :inning, null: false
      t.boolean :top_inning, null: false
      t.integer :runs, default: 0, null: false
      t.timestamps
    end
  end
end
