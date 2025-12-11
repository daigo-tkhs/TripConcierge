# app/mailers/user_mailer.rb (最終確定版)
# frozen_string_literal: true

class UserMailer < ApplicationMailer
  # ActionMailerのconfig/environments.rbの設定をジョブ実行環境に確実に適用させる
  self.default_url_options = Rails.application.config.action_mailer.default_url_options
  
  # メーラー内でルーティングヘルパーを使うためにインクルード（環境依存のバグ対策）
  include Rails.application.routes.url_helpers

  def welcome
    @greeting = 'Hi'
    mail to: params[:to], subject: t('messages.mail.welcome_subject')
  end

  def invite_email
    @invitation = params[:invitation]
    @inviter = params[:inviter]
    @trip = @invitation.trip
    
    # ここで self.default_url_options にホストとプロトコルが設定されているため、
    # invitation_url は絶対URLを正しく生成できる
    @invite_url = invitation_url(@invitation.token)

    subject = t('messages.mail.invite_subject', inviter_name: @inviter.nickname || @inviter.email)

    mail(
      to: @invitation.email,
      subject: subject
    )
  end
end