require 'rails_helper'

RSpec.describe "ChecklistManagements", type: :feature do
  let(:user) { create(:user) }
  let(:trip) { create(:trip, owner: user, title: 'テスト旅行') }
  # 削除テスト用に初期データを作成しておく
  let!(:existing_item) { create(:checklist_item, trip: trip, name: '既存のアイテム') }

  before do
    sign_in user
    visit trip_checklists_path(trip)
  end

  scenario "チェックリストに新しいアイテムを追加できること" do
    # ページ遷移の確認
    expect(page).to have_content('持ち物リスト')

    # --- 入力 ---
    # フォームが複数あるため、新規追加フォーム（クラスで特定）の中にスコープを絞る
    within 'form.flex.gap-2' do
      # このブロック内なら 'checklist_item_name' は1つしかない
      fill_in 'checklist_item_name', with: 'パスポート'
      
      # ボタンクリックも同じブロック内で行う
      find('button[type="submit"]').click
    end

    # --- 検証 ---
    expect(page).to have_current_path(trip_checklists_path(trip))
    
    # 修正: inputのvalueとして表示されているため have_field で確認
    expect(page).to have_field(with: 'パスポート')
    
    # DBに保存されたか確認
    expect(ChecklistItem.where(name: 'パスポート', trip: trip)).to exist
  end

  scenario "アイテム削除ができること" do
    # 修正: inputのvalueとして表示されているため have_field で確認
    expect(page).to have_field(with: '既存のアイテム')

    # --- 削除ボタンクリック ---
    expect {
      # 複数の削除ボタンがある場合、既存アイテム（リストの最初）の削除ボタンをクリック
      # first を使って安全にクリック
      first('button.text-gray-300.hover\:text-red-500').click
    }.to change(ChecklistItem, :count).by(-1)

    # --- 検証 ---
    expect(page).to have_current_path(trip_checklists_path(trip))
    # 削除されたので、その値を持つフィールドが存在しないことを確認
    expect(page).not_to have_field(with: '既存のアイテム')
  end
end