class CreateTeamSeasons < ActiveRecord::Migration[8.1]
  def change
    create_table :team_seasons do |t|
      t.references :team, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.integer :season

      t.timestamps
    end
  end
end
