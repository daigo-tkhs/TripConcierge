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
  has_many :favorites, dependent: :destroy
  has_many :favorited_users, through: :favorites, source: :user

  # 共有ユーザーとの多対多の関連付け
  has_many :trip_users, dependent: :destroy
  has_many :users, through: :trip_users

  # スコープの定義
  
  # 1. ユーザーが閲覧権限を持つすべての旅程を取得
  # (TripUserテーブルを介して、ユーザーが閲覧者、編集者、オーナーのいずれかの権限を持つTripを検索)
  scope :shared_with_user, ->(user) do
    joins(:trip_users)
      .where('trip_users.user_id = ?', user.id)
      .distinct
  end
  # 2. ユーザーがオーナーである旅程を取得
  scope :owned_by_user, ->(user) { where(owner: user) }
  
  # --- 権限チェック用メソッド（追加） ---

  # そのユーザーが「所有者(owner)」権限を持っているか
  def owner?(user)
    trip_users.find_by(user: user)&.owner?
  end

  # そのユーザーが「編集可能(owner または editor)」か
  def editable_by?(user)
    tu = trip_users.find_by(user: user)
    tu && (tu.owner? || tu.editor?)
  end

  # そのユーザーが「閲覧可能(メンバーである)」か
  def viewable_by?(user)
    trip_users.exists?(user: user)
  end

  # そのユーザーにお気に入りされているか確認するメソッド
  def favorited_by?(user)
    favorites.exists?(user_id: user.id)
  end

  # コールバック：旅程作成後に実行
  after_create :set_owner_as_trip_user

  private
  # 旅程作成者をTripUserとして登録し、オーナー権限を付与する
  def set_owner_as_trip_user
    # TripUserを通して、owner (User) をこのTripにowner権限で追加
    trip_users.create!(user: owner, permission_level: :owner)
  end
end