require 'rails_helper'

RSpec.describe "TripCreations", type: :feature do
  let(:user) { create(:user) }
  let(:trip_title) { '沖縄旅行' }
  let(:start_date) { (Date.current + 7.days).strftime('%Y/%m/%d') }
  let(:end_date) { (Date.current + 10.days).strftime('%Y/%m/%d') }

  before do
    sign_in user
    visit trips_path
  end

  scenario "ユーザーが正常に新しい旅程を作成できること" do
    # リンクをクリック
    click_link '新しい旅程を作成' 

    expect(page).to have_current_path(new_trip_path)
    
    # --- フォーム入力 ---
    # 必須項目: タイトル
    fill_in 'trip_title', with: trip_title
    
    # 必須項目: 日付
    fill_in 'trip_start_date', with: start_date
    fill_in 'trip_end_date', with: end_date
    
    # 必須項目: 総予算 (エラーログより必須であることが判明)
    # ビューの f.number_field :total_budget -> ID: trip_total_budget
    fill_in 'trip_total_budget', with: '50000'

    # 必須項目: 旅行のテーマ (エラーログより必須であることが判明)
    # セレクトボックスの選択には select ヘルパーを使用
    # ビュー: f.select :travel_theme -> ID: trip_travel_theme
    select '温泉重視', from: 'trip_travel_theme'

    # 作成ボタンクリック
    expect {
      click_button '旅程を作成'
    }.to change(Trip, :count).by(1)

    # 完了確認
    expect(page).to have_content(trip_title)
    # メッセージの確認 (実際の表示に合わせて調整してください)
    expect(page).to have_content('新しい旅程が作成されました') 
  end

  scenario "不正なデータで旅程を作成しようとした場合、エラーが表示されること" do
    visit new_trip_path
    
    # タイトルを入力せずに日付だけ入力
    fill_in 'trip_start_date', with: start_date
    fill_in 'trip_end_date', with: end_date
    
    # ボタンクリック (保存されないはず)
    expect {
      click_button '旅程を作成'
    }.not_to change(Trip, :count)

    # エラーメッセージの確認
    # 実際の表示 "Titleを入力してください" に合わせる
    expect(page).to have_content('Titleを入力してください')
    
    # バリデーションエラーが複数出ていることも確認可能
    expect(page).to have_content('Total budgetを入力してください')
  end
end