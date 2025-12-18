# app/models/spot.rb
# frozen_string_literal: true

class Spot < ApplicationRecord
  belongs_to :trip

  # scopeを trip_id と day_number にすることで、同じ旅行の同じ日の中で 1, 2, 3... と番号が振られます
  acts_as_list scope: %i[trip_id day_number]

  # ▼ 削除した点: set_position は acts_as_list が自動で行うため不要になりました。

  # 緯度・経度が変更された場合に移動時間を計算するコールバック
  before_save :calculate_travel_time_from_previous, if: -> { (latitude_changed? || longitude_changed?) && geocoded? }

  enum :category, { sightseeing: 0, restaurant: 1, accommodation: 2, other: 3 }

  # バリデーション
  validates :name, presence: true, length: { maximum: 50 }
  validates :estimated_cost, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :travel_time, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  # 緯度・経度がセットされているか判定するヘルパー
  def geocoded?
    latitude.present? && longitude.present?
  end

  private

  def calculate_travel_time_from_previous
    previous_spot = higher_item # acts_as_list の提供する「一つ前の要素を取得する」メソッド
    return unless previous_spot&.geocoded? && geocoded?

    # 以前と同じ計算ロジック（TravelTimeService等があればそれを使用）
    # コントローラー側の計算ロジックと重複する場合は注意が必要ですが、
    # 基本的にはバックグラウンドまたは保存時に計算する方針でOKです
    begin
      self.travel_time = TravelTimeService.new.calculate_time(previous_spot, self)
    rescue => e
      Rails.logger.error "TravelTime calculation failed: #{e.message}"
    end
  end
end