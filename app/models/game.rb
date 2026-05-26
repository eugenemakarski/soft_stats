class Game < ApplicationRecord
  belongs_to :season
  has_many :game_rosters
  has_many :plate_appearances
  has_many :fielding_positions
  has_many :inning_scores

  enum :status, { not_started: 0, in_progress: 1, completed: 2 }

  OUT_RESULTS = %w[strikeout groundout flyout lineout sac_fly sac_bunt fielders_choice double_play].freeze

  def our_score
    inning_scores.where(our_half: true).sum(:runs)
  end

  def their_score
    inning_scores.where(our_half: false).sum(:runs)
  end

  def current_inning
    plate_appearances.maximum(:inning) || 1
  end

  def batting_inning
    (inning_scores.where(our_half: true).maximum(:inning) || 0) + 1
  end

  def active_half(inning)
    our_done = inning_scores.any? { |s| s.inning == inning && s.our_half? }
    their_done = inning_scores.any? { |s| s.inning == inning && !s.our_half? }

    return nil if our_done && their_done

    if is_home
      return :fielding if !their_done
      return :batting if !our_done
    else
      return :batting if !our_done
      return :fielding if !their_done
    end
  end

  # get outs for current batting inning
  def outs
    outs_for(current_inning, current_top_inning)
  end

  # get outs for given top/bottom inning
  def outs_for(inning, is_home)
    plate_appearances
      .where(inning: inning, top_inning: !is_home)
      .sum { |pa| pa.result == "double_play" ? 2 : OUT_RESULTS.include?(pa.result) ? 1 : 0 }
  end

  def runners_on
    half_inning_pas.last&.runners_before || 0
  end

  def next_batter_id
   last_pa = plate_appearances.order(:created_at).last
    return game_rosters.first unless last_pa

   last_batting_order = game_rosters.find_by(player_id: last_pa.player_id)&.batting_order.to_i
    game_rosters.find_by("batting_order > ?", last_batting_order)&.player_id ||
      game_rosters.first&.player_id
  end


  def half_inning_pas
    plate_appearances.where(inning: current_inning, top_inning: current_top_inning)
  end
end
