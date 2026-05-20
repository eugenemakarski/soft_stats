class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.references :team_season, null: false, foreign_key: true
      t.datetime :date
      t.string :opponent

      t.timestamps
    end
  end
end
