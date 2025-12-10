# frozen_string_literal: true

class InvitationsController < ApplicationController
  # GET /invitations/:token
  def accept
    @hide_header = true
    @hide_footer = true

    @invitation = TripInvitation.find_by(token: params[:token])

    if @invitation.nil? || !@invitation.valid_invitation?
      redirect_to root_path, alert: t('messages.invitation.link_invalid')
      return
    end

    if user_signed_in?
      process_join_trip(current_user)
    else
      session[:invitation_token] = @invitation.token
      render :accept
    end
  end

  # POST /invitations/:token/guest
  def accept_guest
    @invitation = TripInvitation.find_by(token: params[:token], accepted_at: nil)

    # 複雑な条件チェックを分離 (Metrics解消)
    error_message = check_invitation_validity

    unless error_message.nil?
      redirect_to root_path, alert: error_message
      return
    end

    # ゲスト参加処理
    user = user_signed_in? ? current_user : User.find_or_create_guest!(@invitation.email)

    if TripUser.create(trip: @invitation.trip, user: user, permission_level: @invitation.role)
      @invitation.update(accepted_at: Time.current)
      redirect_to trip_path(@invitation.trip), notice: t('messages.invitation.guest_join_success')
    else
      redirect_to root_path, alert: t('messages.invitation.approve_failure')
    end
  end

  private

  # ユーザーを旅程に参加させる処理
  def process_join_trip(user)
    trip = @invitation.trip

    if trip.trip_users.exists?(user: user)
      redirect_to trip_path(trip), notice: t('messages.member.welcome_existing', trip_title: trip.title)
      return
    end

    TripUser.create!(user: user, trip: trip, permission_level: @invitation.role)

    @invitation.update!(accepted_at: Time.current)

    redirect_to trip_path(trip), notice: t('messages.member.join_success', trip_title: trip.title)
  end

  # Metrics解消のため追記: 複雑な条件チェックを分離
  def check_invitation_validity
    return t('messages.invitation.link_invalid') unless @invitation

    if @invitation.expires_at.present? && @invitation.expires_at < Time.current
      return t('messages.invitation.link_invalid')
    end

    return t('messages.invitation.login_required') if @invitation.role == 'editor' && !user_signed_in?

    nil # エラーがない場合は nil を返す
  end
end
