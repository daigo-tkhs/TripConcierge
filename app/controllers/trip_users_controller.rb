# frozen_string_literal: true

class TripUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip
  before_action :set_trip_user, only: %i[destroy]
  before_action :check_trip_view_permission

  def create
    user = User.find_by(email: params[:email])

    if user.nil?
      redirect_to sharing_trip_path(@trip), alert: t('messages.member.not_found')
      return
    end

    role = determine_role_for_new_user(user)
    user_name = user.nickname || user.email

    if @trip.trip_users.exists?(user: user)
      # 既存ユーザーの場合は権限を更新 (ここでは単に通知を出すだけにしています)
      redirect_to sharing_trip_path(@trip), alert: t('messages.member.already_member', user_name: user_name)
    elsif @trip.trip_users.create(user: user, permission_level: role)
      role_name = role == 'viewer' ? '閲覧者' : '編集者'
      redirect_to sharing_trip_path(@trip),
                  notice: t('messages.member.invite_success',
                            user_name: user_name, role_name: role_name)
    else
      redirect_to sharing_trip_path(@trip), alert: t('messages.member.invite_failure')
    end
  end

  def destroy
    user_name = @trip_user.user.nickname || @trip_user.user.email

    if @trip_user.user == current_user
      # 自分自身を削除しようとした場合（離脱）
      @trip_user.destroy
      redirect_to trips_path, notice: t('messages.member.leave_success', trip_title: @trip.title), status: :see_other
    elsif @trip.owner == current_user
      # オーナーが他のユーザーを削除
      @trip_user.destroy
      redirect_to sharing_trip_path(@trip),
                  notice: t('messages.member.delete_success', user_name: user_name),
                  status: :see_other
    else
      redirect_to sharing_trip_path(@trip), alert: t('messages.member.delete_permission_denied')
    end
  end

  private

  def determine_role_for_new_user(_user)
    if @trip.editable_by?(current_user)
      params[:role].presence || 'editor'
    else
      'viewer'
    end
  end

  def set_trip
    @trip = Trip.find(params[:trip_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t('messages.trip.not_found_simple') # TripUser用
  end

  def set_trip_user
    @trip_user = @trip.trip_users.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to sharing_trip_path(@trip), alert: t('messages.member.member_not_found')
  end

  def check_trip_view_permission
    return if @trip.viewable_by?(current_user)

    redirect_to root_path, alert: t('messages.member.view_permission_denied')
  end

  def trip_user_params
    params.require(:trip_user).permit(:email, :role)
  end
end
