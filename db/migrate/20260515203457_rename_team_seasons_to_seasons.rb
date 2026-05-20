class RenameTeamSeasonsToSeasons < ActiveRecord::Migration[8.1]
  def self.up
    rename_table :team_seasons, :seasons
  end

  def self.down
    rename_table :seasons, :team_seasons
  end
end
