# frozen_string_literal: true

class Spot < ApplicationRecord
  belongs_to :trip

  # scopeを trip_id と day_number にすることで、同じ旅行の同じ日の中で順序を管理します
  acts_as_list scope: %i[trip_id day_number]

  # 仮想属性: フォームから「時間」と「分」を別々に受け取るためのアクセサ
  attr_writer :duration_hours, :duration_minutes

  # 保存・バリデーションの前にデータを整形する
  before_validation :clean_estimated_cost
  before_validation :calculate_duration # ★追加: 時間と分を duration に変換

  geocoded_by :name
  
  # (AIが適当な座標を送ってきても、ここでGoogle Mapsの正確な座標に置き換わります)
  after_validation :geocode, if: ->(obj){ obj.name.present? }

  enum :category, { sightseeing: 0, restaurant: 1, accommodation: 2, other: 3 }

  # スポット名は必須
  validates :name, presence: { message: "を入力してください" }, length: { maximum: 50 }   
  validates :day_number, presence: { message: "を入力してください" }, numericality: { only_integer: true, greater_than: 0, message: "は1以上の数字で入力してください" }
  
  # 予算と移動時間のバリデーション
  validates :estimated_cost, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :travel_time, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  
  # ★追加: duration（滞在時間）のバリデーションも明示
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  # 緯度・経度がセットされているか判定するヘルパー
  def geocoded?
    latitude.present? && longitude.present?
  end
  
  def duration_hours
    # 入力値があればそれを優先、なければDBの duration から計算 (例: 90分 ÷ 60 = 1時間)
    @duration_hours&.to_i || (duration.present? ? duration / 60 : 0)
  end

  def duration_minutes
    # 入力値があればそれを優先、なければDBの duration から計算 (例: 90分 % 60 = 30分)
    @duration_minutes&.to_i || (duration.present? ? duration % 60 : 0)
  end

  private

  def calculate_duration
    # 時間・分の入力がある場合、分単位に変換して duration に保存
    # to_i を使うことで、nilや空文字も安全に 0 として計算されます
    if @duration_hours.present? || @duration_minutes.present?
      self.duration = (@duration_hours.to_i * 60) + @duration_minutes.to_i
    end
  end

  # 「¥1,000」や「2000.0」といった入力を「1000」「2000」に正しく変換する
  def clean_estimated_cost
    return if estimated_cost.blank?
    
    # 全角数字なども考慮する場合、一度文字列にして整形
    self.estimated_cost = estimated_cost.to_s.gsub(/[^\d.]/, '').to_f.to_i
  end
end