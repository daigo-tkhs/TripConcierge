# frozen_string_literal: true

module ApplicationHelper
  # 分数を「○時間○分」の形式に変換するヘルパー
  def format_duration(minutes)
    return '0分' if minutes.to_i <= 0

    hours = minutes / 60
    mins = minutes % 60

    if hours.positive?
      "#{hours}時間#{mins}分"
    else
      "#{mins}分"
    end
  end
end
