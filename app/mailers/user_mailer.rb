# app/mailers/user_mailer.rb (最終確定版)
# frozen_string_literal: true

class UserMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def welcome
    @greeting = 'Hi'
    mail to: params[:to], subject: t('messages.mail.welcome_subject')
  end

  def invite_email
    @invitation = params[:invitation]
    @inviter = params[:inviter]
    @trip = @invitation.trip
    
    # invitation_url の呼び出しはホスト設定があれば問題なし
    host = Rails.env.production? ? 'travel-shiori.onrender.com' : 'localhost'
    port = Rails.env.production? ? nil : 3000
    protocol = Rails.env.production? ? 'https' : 'http'

    @invite_url = invitation_url(@invitation.token, host: host, port: port, protocol: protocol)

    subject = t('messages.mail.invite_subject', inviter_name: @inviter.nickname || @inviter.email)

    mail(
      to: @invitation.email,
      subject: subject
    )
  end
  
end