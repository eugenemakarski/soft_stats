module GamesHelper
  POSITION_LABELS = {
    1 => "P", 2 => "C", 3 => "1B", 4 => "2B", 5 => "3B",
    6 => "SS", 7 => "LF", 8 => "CF", 9 => "RF", 10 => "EF"
  }.freeze

  def pa_result_chip(result)
    label = case result
    when "single"        then "1B"
    when "double"        then "2B"
    when "triple"        then "3B"
    when "home_run"      then "HR"
    when "walk"          then "BB"
    when "hbp"           then "HBP"
    when "strikeout"     then "K"
    when "groundout"     then "GO"
    when "flyout"        then "FO"
    when "lineout"       then "LO"
    when "sac_fly"       then "SF"
    when "sac_bunt"      then "SB"
    when "double_play"   then "DP"
    when "fielders_choice" then "FC"
    when "error"         then "E"
    else "?"
    end

    color = case result
    when "single", "double", "triple", "home_run" then "bg-green-800 text-green-200"
    when "walk", "hbp"                            then "bg-blue-800 text-blue-200"
    when "sac_fly", "sac_bunt"                    then "bg-yellow-800 text-yellow-200"
    when "error", "fielders_choice"               then "bg-orange-800 text-orange-200"
    else "bg-red-900 text-red-300"
    end

    content_tag(:span, label, class: "text-xs px-1.5 py-0.5 rounded font-bold #{color}")
  end

  def position_label(position_int)
    POSITION_LABELS[position_int] || position_int.to_s
  end
end

