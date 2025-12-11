# frozen_string_literal: true

class InvitationsController < ApplicationController
  before_action :authenticate_user!, only: %i[join]
  
  before_action :set_invitation

  # GET /invitations/:token
  def accept
    @hide_header = true
    @hide_footer = true

    # 未ログインの場合、ログイン後にこの画面に戻ってくるよう保存
    store_location_for(:user, request.fullpath) unless user_signed_in?
  end

  # POST /invitations/:token/join
  def join
    # before_action でログインチェック済み

    # 招待されたメールアドレスとログインユーザーが一致するか確認
    unless @invitation.email == current_user.email
      redirect_to root_path, alert: '招待されたメールアドレスでログインしてください。'
      return
    end

    trip = @invitation.trip

    # すでにメンバーに参加している場合のチェック
    if trip.trip_users.exists?(user: current_user)
      redirect_to trip_path(trip), notice: t('messages.member.welcome_existing', trip_title: trip.title)
      return
    end

    # メンバー追加処理
    TripUser.create!(
      trip: trip,
      user: current_user,
      permission_level: @invitation.role # roleカラムがないためpermission_levelを使用
    )

    # 招待状を使用済みに更新 (user_idカラムがないためaccepted_atのみ)
    @invitation.update!(accepted_at: Time.current)

    redirect_to trip_path(trip), notice: t('messages.member.join_success', trip_title: trip.title)
  end

  # POST /invitations/:token/guest
  def accept_guest    
    if @invitation.valid_invitation?
      session[:guest_token] = @invitation.token
      # ユーザーへの通知メッセージを出し分け
      if @invitation.role == 'editor'
        flash[:notice] = 'ゲストとして閲覧します。（編集機能を利用するにはログインが必要です）'
      else
        flash[:notice] = t('messages.invitation.guest_join_success')
      end
      redirect_to trip_path(@invitation.trip)
    else
      redirect_to root_path, alert: t('messages.invitation.link_invalid')
    end
  end

  private

  def set_invitation
    @invitation = TripInvitation.find_by(token: params[:token])

    # 招待状が存在しない、または有効期限切れ/使用済みの場合
    if @invitation.nil? || !@invitation.valid_invitation?
      redirect_to root_path, alert: t('messages.invitation.link_invalid')
    end
  end
end