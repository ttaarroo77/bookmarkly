class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  
  protected
  
  # サインアップ時のパラメーター設定
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
  
  # アカウント更新時のパラメーター設定
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
  
  # 更新後のリダイレクト先
  def after_update_path_for(resource)
    mypage_path
  end
end