class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :trip

  # 1人のユーザーは同じ旅程を1回しかお気に入りできない
  validates :user_id, uniqueness: { scope: :trip_id }
end