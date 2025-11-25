# app/controllers/spots_controller.rb

class SpotsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip

  def new
    @spot = @trip.spots.build
  end

  def create
    @spot = @trip.spots.build(spot_params)
    
    if @spot.save
      redirect_to trip_path(@trip), notice: 'スポットを追加しました！'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @spot = @trip.spots.find(params[:id])
    @spot.destroy
    redirect_to trip_path(@trip), notice: 'スポットを削除しました。', status: :see_other
  end

  private

  def set_trip
    @trip = Trip.shared_with_user(current_user).find(params[:trip_id])
  end

  def spot_params
    params.require(:spot).permit(:name, :day_number, :estimated_cost, :duration, :booking_url)
  end
end