class TripPolicy < ApplicationPolicy
  # ユーザーがオーナーかどうか
  def owner?
    record.owner == user
  end

  # ユーザーが編集権限を持つメンバーかどうか (オーナーを含む)
  def editor?
    record.editable_by?(user)
  end

  # ユーザーが閲覧権限を持つメンバーかどうか (オーナー、編集者、閲覧者を含む)
  def viewable?
    record.viewable_by?(user)
  end

  # ==================================
  # CRUD操作
  # ==================================

  # index, show は ApplicationPolicyのデフォルト (全て許可) を使用
  # ただし、show は TripsController で viewable_by? を使うため、ここでは viewable? を定義
  def show?
    viewable?
  end

  # 新規作成はログインユーザーなら許可
  def new?
    user.present?
  end

  def create?
    user.present?
  end

  # 更新・削除は編集権限が必要 (ここではオーナーのみと厳格に設定)
  def update?
    owner?
  end

  def destroy?
    owner?
  end
  
  # ==================================
  # 特殊な操作 (TripUsersController用)
  # ==================================
  
  # メンバー追加/削除はオーナーのみに制限
  def manage_members?
    record.owner == user
  end
end