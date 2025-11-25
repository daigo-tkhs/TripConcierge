# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  # Deviseコントローラーが動く時だけ、パラメータ設定メソッドを実行
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # 新規登録時(sign_up)に nickname を許可
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname])
    
    # プロフィール編集時(account_update)にも nickname を許可
    devise_parameter_sanitizer.permit(:account_update, keys: [:nickname])
  end
end