# spec/features/user_authentication_spec.rb (修正版)

require 'rails_helper'

# RSpec.feature ではなく、RSpec.describe を使用し、type: :feature を明示する
RSpec.describe "UserAuthentications", type: :feature do
  let(:user) { create(:user, email: 'test@example.com', password: 'password') }

  # js: true を削除し、デフォルトの rack_test ドライバで実行
  scenario "ユーザーが正常にログインし、ログアウトできること" do
    # ... (処理はそのまま) ...
    visit new_user_session_path
    
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'password'
    click_button 'ログイン'

    expect(page).to have_current_path(trips_path)
    expect(page).to have_content("ログインしました")
    
    click_button 'ログアウト' 
    
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content("ログアウトしました")
  end
end