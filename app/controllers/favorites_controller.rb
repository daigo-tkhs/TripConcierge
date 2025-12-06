class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: [:create, :destroy]

  # お気に入り登録
  def create
    favorite = @trip.favorites.new(user: current_user)
    
    if favorite.save
      # Turbo Streamでボタン部分だけ更新する処理（後ほどViewで作ります）
      # 今回は一旦リダイレクトで実装
      redirect_to trip_path(@trip), notice: 'お気に入りに登録しました'
    else
      redirect_to trip_path(@trip), alert: '登録に失敗しました'
    end
  end

  # お気に入り解除
  def destroy
    favorite = @trip.favorites.find_by(user: current_user)
    favorite&.destroy
    
    redirect_to trip_path(@trip), notice: 'お気に入りを解除しました', status: :see_other
  end

  # 一覧表示
  def index
    # ユーザーがお気に入りした旅程を取得 (N+1問題対策で includes を使用)
    @trips = current_user.favorite_trips.includes(:trip_users).order('favorites.created_at DESC')
  end

  private

  def set_trip
    # 閲覧権限があればお気に入り可能とするため find で取得
    @trip = Trip.find(params[:trip_id])
  end
end