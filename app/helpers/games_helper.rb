module GamesHelper
  POSITION_LABELS = {
    1 => "P", 2 => "C", 3 => "1B", 4 => "2B", 5 => "3B",
    6 => "SS", 7 => "LF", 8 => "CF", 9 => "RF", 10 => "EF"
  }.freeze

  def pa_result_chip(pa)
    result = pa.result
    rbi = pa.rbi.to_i
    label = case result
    when "single"          then "1B"
    when "double"          then "2B"
    when "triple"          then "3B"
    when "home_run"        then "HR"
    when "walk"            then "BB"
    when "strikeout"       then "K"
    when "groundout"       then "GO"
    when "flyout"          then "FLY"
    when "popup"           then "POP"
    when "sac_fly"         then "SAC"
    when "double_play"     then "DP"
    when "fielders_choice" then "FC"
    when "error"           then "E"
    else "?"
    end

    color = case result
    when "single", "double", "triple"             then "bg-blue-800 text-white"
    when "home_run"                               then "bg-green-800 text-white"
    when "walk"                                   then "bg-pink-800 text-white"
    when "sac_fly"                                then "bg-yellow-800 text-white"
    when "strikeout"                              then "bg-red-900 text-white"
    else                                               "bg-orange-800 text-white"
    end

    dots = rbi > 0 ? content_tag(:span, "●" * rbi, class: "text-teal-400 text-xs leading-none") : ""

    content_tag(:span, class: "inline-flex flex-col items-center") do
      content_tag(:span, label, class: "text-xs px-1.5 py-0.5 rounded font-bold #{color}") + dots
    end
  end

  def position_label(position_int)
    POSITION_LABELS[position_int] || position_int.to_s
  end
end
