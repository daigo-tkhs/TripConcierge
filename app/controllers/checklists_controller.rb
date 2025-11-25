# app/controllers/checklists_controller.rb

class ChecklistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip

  def index
    # 新しいアイテム作成用のインスタンス
    @checklist_item = @trip.checklist_items.build
    # 登録済みのアイテム一覧 (未完了を上に、完了済みを下に表示など工夫も可能ですが、まずは単純な登録順)
    @checklist_items = @trip.checklist_items.order(created_at: :asc)
  end

  def create
    @checklist_item = @trip.checklist_items.build(checklist_params)
    
    if @checklist_item.save
      redirect_to trip_checklists_path(@trip), notice: 'アイテムを追加しました。'
    else
      # エラー時は一覧を再表示（データが必要）
      @checklist_items = @trip.checklist_items.order(created_at: :asc)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @checklist_item = @trip.checklist_items.find(params[:id])
    
    # チェック状態の更新（完了/未完了）など
    if @checklist_item.update(checklist_params)
      redirect_to trip_checklists_path(@trip), notice: '更新しました。'
    else
      redirect_to trip_checklists_path(@trip), alert: '更新に失敗しました。'
    end
  end

  private

  def set_trip
    @trip = Trip.shared_with_user(current_user).find(params[:trip_id])
  end

  def checklist_params
    params.require(:checklist_item).permit(:name, :is_checked)
  end
end