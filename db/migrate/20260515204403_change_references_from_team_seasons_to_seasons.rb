class ChangeReferencesFromTeamSeasonsToSeasons < ActiveRecord::Migration[8.1]
  def self.up
    remove_reference :games, :team_season
    add_reference :games, :season
  end

  def self.down
    remove_reference :games, :season
    add_reference :games, :team_season
  end
end
