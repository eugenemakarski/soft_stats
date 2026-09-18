# Batting stats for one player over an arbitrary set of plate appearances.
#
# Build these through .for, which aggregates the whole collection in a fixed
# number of queries (3) instead of the ~11-per-player the stats view used to run.
class PlayerSeasonStats
  HITS = %w[single double triple home_run].freeze
  WALKS = %w[walk hbp].freeze
  SACRIFICES = %w[sac_fly sac_bunt].freeze
  # Reaching on a walk/HBP or giving yourself up on a sacrifice is not an at-bat.
  NON_AT_BATS = (WALKS + SACRIFICES).freeze

  attr_reader :player, :rbi, :runs

  # players             - the roster to report on (players with no PAs get a zeroed row)
  # plate_appearances   - a PlateAppearance relation already scoped to the season/game filter
  def self.for(players:, plate_appearances:)
    counts = counts_by_player(plate_appearances)
    rbi_totals = plate_appearances.group(:player_id).sum(:rbi)
    run_totals = Run.where(plate_appearance_id: plate_appearances.select(:id)).group(:player_id).count

    players.map do |player|
      new(
        player: player,
        result_counts: counts.fetch(player.id, {}),
        rbi: rbi_totals[player.id].to_i,
        runs: run_totals[player.id].to_i
      )
    end
  end

  # => { player_id => { "single" => 3, "walk" => 1, ... } }
  def self.counts_by_player(plate_appearances)
    plate_appearances.group(:player_id, :result).count.each_with_object({}) do |((player_id, result), count), memo|
      name = result_name(result)
      next if name.nil?
      (memo[player_id] ||= Hash.new(0))[name] += count
    end
  end
  private_class_method :counts_by_player

  # Group keys come back as the enum string on some adapters and the raw integer
  # on others, so normalise either shape to the enum name.
  def self.result_name(raw)
    raw.is_a?(Integer) ? PlateAppearance.results.key(raw) : raw&.to_s
  end
  private_class_method :result_name

  def initialize(player:, result_counts:, rbi:, runs:)
    @player = player
    @counts = result_counts
    @rbi = rbi
    @runs = runs
  end

  def plate_appearances = @counts.values.sum
  def at_bats = plate_appearances - count_of(NON_AT_BATS)
  def hits = count_of(HITS)

  def singles = count_of("single")
  def doubles = count_of("double")
  def triples = count_of("triple")
  def home_runs = count_of("home_run")
  def walks = count_of("walk")
  def hit_by_pitch = count_of("hbp")
  def strikeouts = count_of("strikeout")
  def sac_flies = count_of("sac_fly")

  def total_bases = singles + (2 * doubles) + (3 * triples) + (4 * home_runs)

  def average = ratio(hits, at_bats)

  # (H + BB + HBP) / (AB + BB + HBP + SF)
  def on_base_percentage
    ratio(hits + walks + hit_by_pitch, at_bats + walks + hit_by_pitch + sac_flies)
  end

  def slugging = ratio(total_bases, at_bats)
  def ops = on_base_percentage + slugging

  def any_appearances? = plate_appearances.positive?

  private

  def count_of(*names) = names.flatten.sum { |name| @counts.fetch(name, 0) }

  def ratio(numerator, denominator)
    denominator.positive? ? numerator.to_f / denominator : 0.0
  end
end
