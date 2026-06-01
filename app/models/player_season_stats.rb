class PlayerSeasonStats
  def initialize(player, plate_appearances)
    @player = player
    @pas = plate_appearances.where(player_id: player.id)
  end

  def total_pas = @pas.count
  # def hits = @pas.where(result: %w[1B 2B 3B HR]).count
end
