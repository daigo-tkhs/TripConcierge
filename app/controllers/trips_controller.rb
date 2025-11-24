# app/controllers/trips_controller.rb

class TripsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: [:show, :edit, :update, :destroy]
  
  def index
    @trips = Trip.shared_with_user(current_user)
  end

  def new
    @trip = current_user.owned_trips.build
  end

  def create
    @trip = current_user.owned_trips.build(trip_params)
    
    if @trip.save
      # 成功時: 作成された旅程の詳細画面へリダイレクト（routes.rbより@tripに自動対応）
      redirect_to @trip, notice: '新しい旅程が作成されました。AIに詳細を相談しましょう！'
    else
      # 失敗時: 再度新規作成フォームを表示
      flash.now[:alert] = '旅程の作成に失敗しました。必須項目を確認してください。'
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end
  
  private
  
  # Strong Parameters: DBスキーマで定義した必須項目のみを許可
  def trip_params
    params.require(:trip).permit(:title, :start_date, :total_budget, :travel_theme)
  end

  def set_trip
    @trip = Trip.shared_with_user(current_user).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "指定された旅程が見つからないか、アクセス権がありません。"
  end
end