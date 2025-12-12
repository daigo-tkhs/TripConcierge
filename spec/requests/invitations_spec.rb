# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Invitations", type: :request do
  let(:owner) { create(:user) }
  let(:invited_email) { 'invited@example.com' }
  let(:invited_user) { create(:user, email: invited_email) } # 招待メールと一致させるため固定
  let(:uninvited_user) { create(:user) }
  let!(:trip) { create(:trip, owner: owner, title: '酒井市旅行') }
  
  # 招待状: ログインユーザーのメールアドレスと一致させる
  let(:invitation) { create(:trip_invitation, trip: trip, sender: owner, role: 'editor', email: invited_email) }
  
  let(:expired_invitation) { create(:trip_invitation, trip: trip, sender: owner, expires_at: 1.day.ago) }
  let(:accepted_invitation) { create(:trip_invitation, trip: trip, sender: owner, accepted_at: Time.current) }

  # ============================================================================
  # GET /invitations/:token (accept アクション)
  # ============================================================================
  describe "GET /invitations/:token" do
    context "正常系: ログインユーザーの場合" do
      before { sign_in invited_user }

      it "有効な招待の場合、確認画面を表示する" do
        get invitation_path(invitation.token)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("招待を受け取る") 
      end

      it "既に旅程のメンバーである場合、詳細ページにリダイレクトする" do
        # 事前にメンバーとして登録
        create(:trip_user, trip: trip, user: invited_user, permission_level: 'viewer') 

        get invitation_path(invitation.token)
        expect(response).to redirect_to(trip_path(trip))
        expect(flash[:notice]).to be_present 
      end
    end

    context "異常系: 期限切れの場合" do
      it "エラーメッセージと共にルートページにリダイレクトする" do
        get invitation_path(expired_invitation.token)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
    
    context "異常系: 使用済みの場合" do
      it "エラーメッセージと共にルートページにリダイレクトする" do
        get invitation_path(accepted_invitation.token)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  # ============================================================================
  # POST /invitations/:token/join (join アクション: ログインユーザー)
  # ============================================================================
  describe "POST /invitations/:token/join" do
    context "正常系: 参加確定 (招待メールとログインメールが一致)" do
      before { sign_in invited_user }

      it "TripUserレコードが作成され、詳細ページにリダイレクトされること" do
        expect {
          post join_invitation_path(invitation.token)
        }.to change(TripUser, :count).by(1)
        
        expect(response).to redirect_to(trip_path(trip))
        expect(flash[:notice]).to be_present
      end

      it "招待状のaccepted_atが更新されること" do
        post join_invitation_path(invitation.token)
        invitation.reload
        expect(invitation.accepted_at).not_to be_nil
      end
    end
    
    context "異常系: 招待されたメールアドレスと異なるユーザーでログイン" do
      before { sign_in uninvited_user }

      it "TripUserレコードは作成されず、ルートにリダイレクトされること" do
        expect {
          post join_invitation_path(invitation.token)
        }.not_to change(TripUser, :count)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  # ============================================================================
  # POST /invitations/:token/guest (accept_guest アクション: ゲスト参加)
  # ============================================================================
  describe "POST /invitations/:token/guest" do
    context "正常系: ゲスト参加確定" do
      it "TripUserレコードは作成されず（セッション保存）、詳細ページにリダイレクトされること" do
        expect {
          post accept_guest_invitation_path(invitation.token)
        }.not_to change(TripUser, :count)
        
        expect(session[:guest_token]).to eq invitation.token 
        expect(response).to redirect_to(trip_path(trip))
      end
    end
    
    context "異常系: 期限切れの場合" do
      it "リダイレクトされ、TripUserレコードは作成されないこと" do
        expect {
          post accept_guest_invitation_path(expired_invitation.token)
        }.not_to change(TripUser, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end