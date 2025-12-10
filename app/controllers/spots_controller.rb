# frozen_string_literal: true

class SpotsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip
  before_action :set_spot, only: %i[edit update destroy move]
  before_action :authorize_editor!
  before_action :hide_global_header, only: %i[new create edit update]

  def new
    @spot = @trip.spots.build
  end

  def edit
    # set_spot で @spot が取得されているため、ここは空でOK
  end

  def create
    @spot = @trip.spots.build(spot_params)

    if @spot.save
      redirect_to trip_path(@trip), notice: t('messages.spot.create_success')
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @spot.update(spot_params)
      redirect_to trip_path(@trip), notice: t('messages.spot.update_success')
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @spot.destroy
    redirect_to trip_path(@trip), notice: t('messages.spot.delete_success'), status: :see_other
  end

  # --- 並び替え処理 ---
  def move
    new_day = params[:day_number].to_i
    new_position = params[:position].to_i

    Spot.transaction do
      @spot.update!(day_number: new_day) if new_day.positive? && @spot.day_number != new_day
      @spot.insert_at(new_position)
    end
    head :ok
  rescue StandardError => e
    Rails.logger.error "Move failed: #{e.message}"
    head :unprocessable_content
  end

  private

  def set_trip
    @trip = Trip.shared_with_user(current_user).find(params[:trip_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t('messages.trip.not_found')
  end

  def set_spot
    @spot = @trip.spots.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to trip_path(@trip), alert: t('messages.spot.not_found')
  end

  def authorize_editor!
    return if @trip.editable_by?(current_user)

    redirect_to trip_path(@trip), alert: t('messages.spot.permission_denied')
  end

  def hide_global_header
    @hide_header = true
  end

  def spot_params
    params.require(:spot).permit(:name, :day_number, :estimated_cost, :duration, :booking_url, :reservation_required)
  end
end
