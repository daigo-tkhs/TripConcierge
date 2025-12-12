class ChecklistItemPolicy < ApplicationPolicy
  
  # index, show 権限は、親である旅程の閲覧権限に依存する
  def show?
    # record は ChecklistItem オブジェクトを想定
    TripPolicy.new(user, record.trip).show?
  end

  # 作成、更新、削除の権限は、旅程の編集権限に依存する
  def create?
    TripPolicy.new(user, record.trip).editor?
  end

  def update?
    TripPolicy.new(user, record.trip).editor?
  end
  
  def destroy?
    TripPolicy.new(user, record.trip).editor?
  end
  
  # import アクションの権限チェック用
  def import?
    create?
  end

  # index アクション用 (TripPolicy#show? に委譲)
  def index?
    TripPolicy.new(user, record.trip).show?
  end
end