# frozen_string_literal: true

module TripsHelper
  def theme_badge_class(theme)
    case theme
    when '温泉重視'
      'bg-orange-100 text-orange-700 border border-orange-200'
    when '食体験重視'
      'bg-yellow-100 text-yellow-800 border border-yellow-200'
    when 'アクティビティ重視'
      'bg-green-100 text-green-700 border border-green-200'
    when 'リラックス'
      'bg-teal-100 text-teal-700 border border-teal-200'
    when '観光スポット巡り'
      'bg-indigo-100 text-indigo-700 border border-indigo-200'
    else # その他、または未設定
      'bg-gray-100 text-gray-700 border border-gray-200'
    end
  end

  def trip_days_options(trip)
    days = []
    # 期間計算（終了日がなければ1日のみ）
    duration = (trip.end_date ? (trip.end_date - trip.start_date).to_i + 1 : 1)

    (1..duration).each do |day_num|
      date = trip.start_date + (day_num - 1).days
      label = "#{day_num}日目 (#{date.strftime('%m/%d')})"
      days << [label, day_num]
    end
    days
  end
end
