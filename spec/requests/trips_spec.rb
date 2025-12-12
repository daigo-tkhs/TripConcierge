# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Trips", type: :request do
  # テストデータ
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:trip) { create(:trip, owner: user, title: "既存の旅程") }

  # 共通処理: 基本的に所有者(user)でログインしておく
  before do
    sign_in user
  end

  # ============================================================================
  # GET /trips (一覧ページ)
  # ============================================================================
  describe "GET /trips" do
    context "正常系" do
      it "ログインユーザーがアクセスすると、正常にレスポンスが返ってくること" do
        get trips_path
        expect(response).to have_http_status(:success) # 200 OK
        expect(response.body).to include("既存の旅程") # 作成済みデータが表示されているか
      end
    end
  end

  # ============================================================================
  # GET /trips/:id (詳細ページ)
  # ============================================================================
  describe "GET /trips/:id" do
    context "正常系" do
      it "所有者がアクセスした場合、詳細ページが表示されること" do
        get trip_path(trip)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(trip.title)
      end
    end

    context "異常系: 権限エラー" do
      before { sign_in other_user } # 別のユーザーでログインし直す

      it "無関係なユーザーがアクセスした場合、リダイレクトされること" do
        get trip_path(trip)
        # 実装によってリダイレクト先は root_path や trips_path など異なります
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  # ============================================================================
  # POST /trips (新規作成)
  # ============================================================================
  describe "POST /trips" do
    context "正常系" do
      let(:valid_params) { { trip: attributes_for(:trip, title: "新しい旅") } }

      it "有効なパラメータの場合、新しい旅程が作成されること" do
        expect {
          post trips_path, params: valid_params
        }.to change(Trip, :count).by(1)
      end

      it "作成後に詳細ページへリダイレクトされること" do
        post trips_path, params: valid_params
        expect(response).to redirect_to(trip_path(Trip.last))
      end
    end

    context "異常系: バリデーションエラー" do
      let(:invalid_params) { { trip: attributes_for(:trip, title: "") } } # タイトル空

      it "無効なパラメータの場合、旅程が作成されないこと" do
        expect {
          post trips_path, params: invalid_params
        }.not_to change(Trip, :count)
      end

      it "エラー等のため、再度新規作成ページが表示されること（またはUnprocessable Entity）" do
        post trips_path, params: invalid_params
        # Rails 7系ではバリデーションエラー時に :unprocessable_entity (422) を返すのが標準
        # もし単に render :new しているだけなら :success (200) になる場合もあります
        if response.status == 422
          expect(response).to have_http_status(:unprocessable_entity)
        else
          expect(response).to have_http_status(:success) # render :new
        end
      end
    end
  end
end