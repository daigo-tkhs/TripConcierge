class TripUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip

  # メンバー追加 (招待)
  def create
    # メールアドレスからユーザーを検索
    email = params[:email]
    user = User.find_by(email: email)

    if user.nil?
      redirect_to sharing_trip_path(@trip), alert: "指定されたメールアドレスのユーザーは見つかりませんでした。"
      return
    end

    # 既にメンバーかチェック
    if @trip.trip_users.exists?(user_id: user.id)
      redirect_to sharing_trip_path(@trip), alert: "#{user.name || user.email} は既にメンバーです。"
      return
    end

    # メンバーとして追加 (デフォルトは編集者: editor)
    # ※ 閲覧者(viewer)を選ばせたい場合は params[:role] を使います
    role = params[:role] || :editor
    
    @trip.trip_users.create!(user: user, permission_level: role)

    redirect_to sharing_trip_path(@trip), notice: "#{user.name || user.email} を招待しました！"
  end

  # メンバー削除
  def destroy
    trip_user = @trip.trip_users.find(params[:id])
    
    # 自分自身やオーナーは削除できないようにする制御などが本来は必要
    # 今回はシンプルに「オーナーだけが他者を削除できる」前提で進めます
    
    user_name = trip_user.user.name || trip_user.user.email
    trip_user.destroy
    
    redirect_to sharing_trip_path(@trip), notice: "#{user_name} をメンバーから削除しました。", status: :see_other
  end

  private

  def set_trip
    @trip = Trip.find(params[:trip_id])
    
    # 権限チェック: オーナー以外はメンバー操作できないようにする
    unless @trip.owner?(current_user)
      redirect_to trip_path(@trip), alert: "メンバー管理の権限がありません。"
    end
  end
end