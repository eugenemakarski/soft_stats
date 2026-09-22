class Game < ApplicationRecord
  belongs_to :season
  has_many :game_rosters
  has_many :plate_appearances
  has_many :fielding_positions
  has_many :inning_scores

  enum :status, { not_started: 0, in_progress: 1, completed: 2 }
  enum :game_type, { regular: 0, playoff: 1 }, prefix: true

  OUT_RESULTS = %w[strikeout groundout flyout lineout popup sac_fly sac_bunt fielders_choice double_play].freeze

  scope :chronological, -> { reorder(date: :asc, id: :asc) }
  scope :newest_first, -> { reorder(date: :desc, id: :desc) }
  scope :visible_to, ->(user) {
    joins(season: { team: :team_memberships }).where(team_memberships: { user_id: user.id })
  }

  delegate :team, to: :season

  # Narrows to one game_type when given a valid one; otherwise leaves the scope alone
  # so callers can pass an unfiltered "All" straight through.
  scope :of_type, ->(type) {
    type.present? && Game.game_types.key?(type.to_s) ? where(game_type: type.to_s) : all
  }

  GAME_TYPE_LABELS = {
    "regular" => "Regular season",
    "playoff" => "Playoffs"
  }.freeze

  def self.game_type_label(type)
    GAME_TYPE_LABELS.fetch(type.to_s, type.to_s.humanize)
  end

  def game_type_label
    self.class.game_type_label(game_type)
  end

  # Summed in Ruby so a preloaded includes(:inning_scores) is used, rather than
  # two queries per game on the games list.
  def our_score
    inning_scores.select(&:our_half?).sum(&:runs)
  end

  def their_score
    inning_scores.reject(&:our_half?).sum(&:runs)
  end

  # Nothing sets status: completed yet, so a game counts as decided as soon as
  # any half-inning is scored — an in-progress game reports its current score.
  def scored?
    inning_scores.any?
  end

  def outcome
    return nil unless scored?

    case our_score <=> their_score
    when 1 then :win
    when -1 then :loss
    else :tie
    end
  end

  def inning_score(inning, our_half)
    inning_scores.where(our_half: our_half, inning: inning)
  end

  def batting_inning
    (inning_scores.where(our_half: true).maximum(:inning) || 0) + 1
  end

  def fielding_inning
    (inning_scores.where(our_half: false).maximum(:inning) || 0) + 1
  end

  def current_inning
    [ batting_inning, fielding_inning ].min
  end

  def active_half(inning)
  scores = inning_scores.reload
    our_done = scores.any? { |s| s.inning == inning && s.our_half? }
    their_done = scores.any? { |s| s.inning == inning && !s.our_half? }

    return nil if our_done && their_done

    if is_home
      return :fielding if !their_done
      :batting if !our_done
    else
      return :batting if !our_done
      :fielding if !their_done
    end
  end

  # get outs for given top/bottom inning
  def outs(inning, is_home)
    plate_appearances
      .where(inning: inning, top_inning: !is_home)
      .sum { |pa| pa.result == "double_play" ? 2 : OUT_RESULTS.include?(pa.result) ? 1 : 0 }
  end

  def runners_on
    half_inning_pas.last&.runners_before || 0
  end

  def next_batter_id
   last_pa = plate_appearances.order(:created_at).last
   available = game_rosters.where(available: true)
   return available.first&.player_id unless last_pa

   last_batting_order = available.find_by(player_id: last_pa.player_id)&.batting_order.to_i
   available.find_by("batting_order > ?", last_batting_order)&.player_id ||
    available.first&.player_id
  end

  def players_with_ab_this_inning
    plate_appearances.where(inning: current_inning).pluck(:player_id)
  end

  def half_inning_pas
    plate_appearances.where(inning: current_inning, top_inning: current_top_inning)
  end
end
