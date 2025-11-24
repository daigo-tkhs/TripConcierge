# app/models/trip.rb

class Trip < ApplicationRecord
  # 存在性の検証（必須項目）
  validates :title, presence: true
  validates :start_date, presence: true
  validates :total_budget, presence: true
  validates :travel_theme, presence: true

  # データ型の検証 (total_budgetは数値である必要がある)
  validates :total_budget, numericality: { only_integer: true, greater_than_or_equal_to: 0 }


  # 旅程の作成者（オーナー）とのカスタム関連付け
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'

  # 1対多の関連付け
  has_many :spots, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :checklist_items, dependent: :destroy

  # 共有ユーザーとの多対多の関連付け
  has_many :trip_users, dependent: :destroy
  has_many :users, through: :trip_users
end