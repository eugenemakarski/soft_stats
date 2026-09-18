class PlayerPitchingStats
  INNINGS_PER_GAME = 9

  attr_reader :player, :games, :innings_pitched, :runs_allowed, :wins, :losses, :ties

  def self.for(games:)
    game_ids = games.pluck(:id)
    return [] if game_ids.empty?

    pitcher_by_game = GameRoster.where(game_id: game_ids, is_pitcher: true).pluck(:game_id, :player_id).to_h
    return [] if pitcher_by_game.empty?

    totals = Hash.new { |hash, key| hash[key] = blank_totals }

    line_by_game(game_ids).each do |game_id, line|
      player_id = pitcher_by_game[game_id]
      next unless player_id

      total = totals[player_id]
      total[:games] += 1
      total[:innings_pitched] += line[:innings]
      total[:runs_allowed] += line[:runs_against]

      case line[:runs_for] <=> line[:runs_against]
      when 1 then total[:wins] += 1
      when -1 then total[:losses] += 1
      else total[:ties] += 1
      end
    end

    players_by_id = Player.where(id: totals.keys).index_by(&:id)

    totals.filter_map do |player_id, total|
      player = players_by_id[player_id]
      player && new(player: player, **total)
    end.sort_by { |stats| [ -stats.innings_pitched, stats.player.name.to_s ] }
  end

  # => { game_id => { innings:, runs_against:, runs_for: } }, only for games that
  # have at least one scored half-inning.
  def self.line_by_game(game_ids)
    InningScore.where(game_id: game_ids).pluck(:game_id, :our_half, :runs)
      .each_with_object({}) do |(game_id, our_half, runs), memo|
        line = (memo[game_id] ||= { innings: 0, runs_against: 0, runs_for: 0 })
        if our_half
          line[:runs_for] += runs.to_i
        else
          # One inning_scores row per half-inning we pitched == one inning pitched.
          line[:innings] += 1
          line[:runs_against] += runs.to_i
        end
      end
  end
  private_class_method :line_by_game

  def self.blank_totals
    { games: 0, innings_pitched: 0, runs_allowed: 0, wins: 0, losses: 0, ties: 0 }
  end
  private_class_method :blank_totals

  def initialize(player:, games:, innings_pitched:, runs_allowed:, wins:, losses:, ties:)
    @player = player
    @games = games
    @innings_pitched = innings_pitched
    @runs_allowed = runs_allowed
    @wins = wins
    @losses = losses
    @ties = ties
  end

  def record
    ties.positive? ? "#{wins}-#{losses}-#{ties}" : "#{wins}-#{losses}"
  end

  def era
    return 0.0 unless innings_pitched.positive?
    runs_allowed * INNINGS_PER_GAME.to_f / innings_pitched
  end
end
