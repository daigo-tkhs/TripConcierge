# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Rails.env.test? 以外で Basic認証を適用
  before_action :basic_auth, unless: -> { Rails.env.test? }
  
  # Deviseコントローラーが動く時だけ、パラメータ設定メソッドを実行
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # ★★★ 修正箇所: after_sign_in_path_for を統一する ★★★
  # Deviseのサインイン成功後のリダイレクト先を決定
  def after_sign_in_path_for(resource)
    # 招待トークンがあれば処理を実行
    invitation_path = handle_invitation_acceptance(resource)
    return invitation_path if invitation_path.present?

    # 招待がない場合は、デフォルトの旅程一覧へ
    trips_path
  end
  # ★★★ 修正箇所終了 ★★★


  protected

  def configure_permitted_parameters
    # 新規登録時(sign_up)に nickname を許可
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname])

    # プロフィール編集時(account_update)にも nickname を許可
    devise_parameter_sanitizer.permit(:account_update, keys: [:nickname])
  end

  def after_sign_out_path_for(_resource_or_scope)
    # ログアウト後のリダイレクト先をログイン画面に設定
    new_user_session_path
  end

  private

  # 招待トークンを確認し、自動参加処理を実行
  def handle_invitation_acceptance(user)
    token = session[:invitation_token]

    if token.present?
      invitation = TripInvitation.find_by(token: token)

      if invitation.present? && !invitation.accepted?
        # 招待状を使用済みにマーク
        invitation.update(accepted_at: Time.current)

        # TripUserを作成（参加処理）
        # find_or_create_by を利用して重複作成を防止
        invitation.trip.trip_users.find_or_create_by(user: user) do |trip_user|
          trip_user.permission_level = invitation.role # 権限を招待状から引き継ぐ
        end

        # 成功したらセッションをクリア
        session.delete(:invitation_token)

        # Flashメッセージを直接設定し、リダイレクトパスのみを返す
        flash[:notice] = "#{invitation.trip.title} の招待を受け入れました！"
        return trip_path(invitation.trip)
      else
        # 招待が無効な場合はセッションをクリア
        session.delete(:invitation_token)
      end
    end

    nil
  end

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['BASIC_AUTH_USER'] && password == ENV['BASIC_AUTH_PASSWORD']
    end
  end
  
  def user_not_authorized
    flash[:alert] = "この操作を行う権限がありません。"
    # 権限がない場合、一つ前のページに戻す（なければルートパス）
    redirect_back(fallback_location: root_path)
  end
end