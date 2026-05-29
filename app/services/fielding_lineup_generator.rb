# app/services/fielding_lineup_generator.rb
#
# Generates a fielding lineup for all innings of a game.
#
# Two-step process per inning:
#   1. Bench fairness  — pick WHO plays based on bench_equivalent count
#   2. Position matching — assign WHICH position via min-cost bipartite matching (TODO)
#
# bench_equivalent: innings spent sitting OR catching (both count equally)
# No player catches more than once per game.
# Pitcher is fixed for the whole game and excluded from rotation (TODO: add pitcher boolean to game_rosters)

class FieldingLineupGenerator
  FIELD_POSITIONS = [2, 3, 4, 5, 6, 7, 8, 9].freeze  # excludes pitcher (1)
  DEFAULT_INNINGS = 6

  def initialize(game, innings: DEFAULT_INNINGS)
    @game = game
    @innings = innings

    # TODO: exclude pitcher once game_rosters.pitcher column exists
    # For now, all available players are in the rotation
    @players = game.game_rosters
                   .where(available: true)
                   .includes(player: { player_teams: :player_positions })
                   .to_a
  end

  def generate_and_save
    schedule = generate

    records = schedule.flat_map do |inn|
      inn[:assignments].map do |player_id, position|
        { game_id: @game.id, player_id: player_id, position: position, inning: inn[:inning] }
      end
    end

    FieldingPosition.where(game_id: @game.id).delete_all
    FieldingPosition.insert_all(records)

    schedule
  end

  def generate
    bench_equivalent = @players.each_with_object({}) { |r, h| h[r.player_id] = 0 }
    has_caught       = @players.each_with_object({}) { |r, h| h[r.player_id] = false }

    schedule = []

    @innings.times do |i|
      inning = i + 1

      playing, sitting = select_players(bench_equivalent)
      sitting.each { |r| bench_equivalent[r.player_id] += 1 }

      cost_matrix = build_cost_matrix(playing, has_caught)
      assignment  = hungarian(cost_matrix)

      inning_assignments = {}
      assignment.each_with_index do |pos_idx, player_idx|
        player_id = playing[player_idx].player_id
        position  = FIELD_POSITIONS[pos_idx]

        if position == 2
          bench_equivalent[player_id] += 1
          has_caught[player_id] = true
        end

        inning_assignments[player_id] = position
      end

      schedule << {
        inning: inning,
        assignments: inning_assignments,
        sitting: sitting.map(&:player_id)
      }
    end

    schedule
  end

  private

  # Returns [playing, sitting] arrays of game_roster records.
  # Players with the highest bench_equivalent get priority to play.
  # Ties broken by batting_order (lower = plays first when tied).
  def select_players(bench_equivalent)
    sorted = @players.sort_by { |r| [-bench_equivalent[r.player_id], r.batting_order.to_i] }
    playing = sorted.first(FIELD_POSITIONS.size)
    sitting = sorted.drop(FIELD_POSITIONS.size)
    [playing, sitting]
  end

  # Builds an n×n cost matrix: rows=players, cols=FIELD_POSITIONS.
  # Uses player_positions costs; infinity for catcher if already caught;
  # high penalty (100) if player has no entry for that position.
  def build_cost_matrix(playing, has_caught)
    playing.map do |roster|
      player_team = roster.player.player_teams.find { |pt| pt.season_id == @game.season_id }
      pos_costs   = (player_team&.player_positions || []).each_with_object({}) do |pp, h|
        h[pp.position] = pp.cost
      end

      FIELD_POSITIONS.map do |pos|
        if pos == 2 && has_caught[roster.player_id]
          999
        else
          pos_costs[pos] || 100
        end
      end
    end
  end

  # O(n³) Hungarian algorithm for minimum cost perfect matching.
  # Returns assignment array where assignment[player_idx] = position_idx.
  def hungarian(cost_matrix)
    n   = cost_matrix.size
    inf = Float::INFINITY

    u   = Array.new(n + 1, 0)
    v   = Array.new(n + 1, 0)
    p   = Array.new(n + 1, 0)
    way = Array.new(n + 1, 0)

    (1..n).each do |i|
      p[0]    = i
      j0      = 0
      minval  = Array.new(n + 1, inf)
      used    = Array.new(n + 1, false)

      loop do
        used[j0] = true
        i0       = p[j0]
        delta    = inf
        j1       = nil

        (1..n).each do |j|
          next if used[j]
          cur = cost_matrix[i0 - 1][j - 1] - u[i0] - v[j]
          if cur < minval[j]
            minval[j] = cur
            way[j]    = j0
          end
          if minval[j] < delta
            delta = minval[j]
            j1    = j
          end
        end

        (0..n).each do |j|
          if used[j]
            u[p[j]] += delta
            v[j]    -= delta
          else
            minval[j] -= delta
          end
        end

        j0 = j1
        break if p[j0] == 0
      end

      until j0 == 0
        p[j0] = p[way[j0]]
        j0    = way[j0]
      end
    end

    # p[j] = row assigned to column j (1-indexed) → convert to 0-indexed answer
    ans = Array.new(n)
    (1..n).each { |j| ans[p[j] - 1] = j - 1 if p[j] != 0 }
    ans
  end
end
