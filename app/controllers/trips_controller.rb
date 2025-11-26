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
      # 成功時: 作成された旅程の詳細画面へリダイレクト
      redirect_to @trip, notice: '新しい旅程が作成されました。AIに詳細を相談しましょう！'
    else
      # 失敗時: 再度新規作成フォームを表示
      flash.now[:alert] = '旅程の作成に失敗しました。必須項目を確認してください。'
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @trip.update(trip_params)
      redirect_to @trip, notice: '旅程を更新しました。'
    else
      flash.now[:alert] = '更新に失敗しました。入力内容を確認してください。'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @trip.destroy
    redirect_to trips_path, notice: '旅程を削除しました。', status: :see_other
  end

  private

  def trip_params
    params.require(:trip).permit(:title, :start_date, :total_budget, :travel_theme)
  end

  def set_trip
    @trip = Trip.shared_with_user(current_user).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "指定された旅程が見つからないか、アクセス権がありません。"
  end
end