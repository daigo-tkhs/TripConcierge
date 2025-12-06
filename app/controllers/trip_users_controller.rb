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

    if @trip.trip_users.exists?(user_id: user.id)
      redirect_to sharing_trip_path(@trip), alert: "#{user.nickname || user.email} は既にメンバーです。"
      return
    end

    # 自分が「編集可能(Owner/Editor)」なら、指定されたロールを使う
    # 自分が「閲覧者(Viewer)」なら、強制的に「Viewer」として招待する
    if @trip.editable_by?(current_user)
      role = params[:role] || :editor
    else
      role = :viewer
    end
    
    @trip.trip_users.create!(user: user, permission_level: role)

    redirect_to sharing_trip_path(@trip), notice: "#{user.nickname || user.email} を#{role == :viewer ? '閲覧者' : '編集者'}として招待しました！"
  end

  # メンバー削除
  def destroy
    # 削除は引き続きオーナーのみ可能とする
    unless @trip.owner?(current_user)
      redirect_to sharing_trip_path(@trip), alert: "メンバーを削除する権限がありません。"
      return
    end

    trip_user = @trip.trip_users.find(params[:id])
    user_name = trip_user.user.nickname || trip_user.user.email
    trip_user.destroy
    
    redirect_to sharing_trip_path(@trip), notice: "#{user_name} をメンバーから削除しました。", status: :see_other
  end

  private

  def set_trip
    @trip = Trip.find(params[:trip_id])
    
    # ★修正: 「オーナーのみ」制限を外し、「閲覧可能ならOK」にする
    unless @trip.viewable_by?(current_user)
      redirect_to trip_path(@trip), alert: "権限がありません。"
    end
  end
end