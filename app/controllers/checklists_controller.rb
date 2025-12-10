# frozen_string_literal: true

class ChecklistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip
  before_action :set_checklist_item, only: %i[update destroy]

  def index
    @hide_header = true
    @checklist_items = @trip.checklist_items.order(created_at: :asc)
    @checklist_item = ChecklistItem.new
  end

  def create
    @checklist_item = @trip.checklist_items.build(checklist_item_params)

    if @checklist_item.save
      redirect_to trip_checklists_path(@trip),
                  notice: t('messages.checklist.create_success',
                            name: @checklist_item.name)
    else
      @checklist_items = @trip.checklist_items.order(created_at: :asc)
      render :index, status: :unprocessable_content
    end
  end

  def update
    @checklist_item.update(checklist_item_params)
    redirect_to trip_checklists_path(@trip)
  end

  def destroy
    @checklist_item.destroy
    redirect_to trip_checklists_path(@trip),
                notice: t('messages.checklist.delete_success',
                          name: @checklist_item.name),
                status: :see_other
  end

  # 自動生成（プリセットの追加）
  def import
    presets = ['パスポート', '現金・クレジットカード', 'スマートフォン・充電器', '着替え', '洗面用具', '常備薬', '雨具']

    presets.each do |name|
      @trip.checklist_items.find_or_create_by(name: name)
    end

    redirect_to trip_checklists_path(@trip), notice: t('messages.checklist.import_success')
  end

  private

  def set_trip
    @trip = Trip.shared_with_user(current_user).find(params[:trip_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t('messages.trip.not_found')
  end

  def set_checklist_item
    @checklist_item = @trip.checklist_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to trip_checklists_path(@trip), alert: t('messages.checklist.item_not_found')
  end

  def checklist_item_params
    params.require(:checklist_item).permit(:name, :is_checked)
  end
end
