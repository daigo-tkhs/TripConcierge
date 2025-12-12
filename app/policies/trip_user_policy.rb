class TripUserPolicy < ApplicationPolicy
  # TripUserレコードの削除（destroy）権限を定義
  def destroy?
    # 1. ユーザー自身が自分の TripUser レコードを削除する場合 (離脱)
    return true if record.user == user

    # 2. Tripのオーナーが他の TripUser レコードを削除する場合
    record.trip.owner == user
  end
end