# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  # FactoryBotで作成したデータを使用
  let(:user) { build(:user) }

  describe 'バリデーション' do
    # ------------------------------------------------------------------
    # 正常系: 有効なデータ
    # ------------------------------------------------------------------
    context '正常系' do
      it 'すべての値（email, password, nickname）が正しく設定されていれば有効であること' do
        expect(user).to be_valid
      end
    end

    # ------------------------------------------------------------------
    # 異常系: 必須項目(presence)
    # ------------------------------------------------------------------
    context '異常系: 必須項目の欠如' do
      it 'メールアドレスがない場合は無効であること' do
        user.email = nil
        expect(user).to be_invalid
        expect(user.errors[:email]).to include("を入力してください")
      end

      it 'パスワードがない場合は無効であること' do
        user.password = nil
        expect(user).to be_invalid
        expect(user.errors[:password]).to include("を入力してください")
      end

      it 'ニックネームがない場合は無効であること' do
        user.nickname = nil
        expect(user).to be_invalid
        expect(user.errors[:nickname]).to include("を入力してください")
      end
    end

    # ------------------------------------------------------------------
    # 異常系: 一意性(uniqueness)
    # ------------------------------------------------------------------
    context '異常系: 重複チェック' do
      it '重複したメールアドレスは登録できないこと' do
        # 1人目を保存
        create(:user, email: 'duplicate@example.com')
        
        # 2人目を同じメアドで作成
        user.email = 'duplicate@example.com'
        expect(user).to be_invalid
        expect(user.errors[:email]).to include("はすでに存在します")
      end
    end

    # ------------------------------------------------------------------
    # 異常系: 文字数・形式(length/format)
    # ------------------------------------------------------------------
    context '異常系: 文字数・形式' do
      it 'パスワードが6文字未満の場合は無効であること' do
        user.password = '12345'
        user.password_confirmation = '12345'
        expect(user).to be_invalid
        expect(user.errors[:password]).to include("は6文字以上で入力してください")
      end

      it 'ニックネームが長すぎる場合（例: 51文字以上）は無効であること' do
        # モデルに length: { maximum: 50 } がある前提のテスト
        user.nickname = 'a' * 51 
        expect(user).to be_invalid
        # エラーメッセージの確認（文言はRailsのデフォルト設定による）
        expect(user.errors[:nickname]).to include("は50文字以内で入力してください")
      end
    end
  end

  # ------------------------------------------------------------------
  # 関連付けと削除の連動(Associations)
  # ------------------------------------------------------------------
  describe '関連付けと削除依存性 (dependent: :destroy)' do
    it 'ユーザーを削除すると、所有している旅程(owned_trips)も削除されること' do
      user.save!
      create(:trip, owner: user) # ユーザーが所有する旅を作成
      
      expect { user.destroy }.to change(Trip, :count).by(-1)
    end

    it 'ユーザーを削除すると、参加情報(trip_users)も削除されること' do
      user.save!
      other_trip = create(:trip)
      create(:trip_user, trip: other_trip, user: user) # 他の旅に参加
      
      expect { user.destroy }.to change(TripUser, :count).by(-1)
    end
    
    it 'ユーザーを削除すると、お気に入り(favorites)も削除されること' do
      # Favoriteのモデル/Factoryがある前提の確認
      association = described_class.reflect_on_association(:favorites)
      expect(association.macro).to eq :has_many
      expect(association.options[:dependent]).to eq :destroy
    end
  end
end