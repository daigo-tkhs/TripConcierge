# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome
    @greeting = 'Hi'
    # subject: '【TripConcierge】ようこそ！旅の準備を始めましょう' を置換
    mail to: params[:to], subject: t('messages.mail.welcome_subject')
  end

  def invite_to_trip
    @trip = params[:trip]
    @inviter = params[:inviter]
    @token = params[:invitation_token]
    @invitation_url = url_for(
      controller: 'invitations',
      action: 'accept',
      token: @token,
      only_path: false
    )

    # subject: "【TripConcierge】#{@inviter.nickname}さんから旅の招待状が届いています" を置換
    mail(
      to: params[:to],
      # i18nの subject に動的な値 (inviter_name) を渡します
      subject: t('messages.mail.invite_subject', inviter_name: @inviter.nickname)
    )
  end
end
