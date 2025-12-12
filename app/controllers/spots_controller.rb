# frozen_string_literal: true
require 'uri'
require 'net/http'
require 'json' # API応答をパースするために使用

class SpotsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip
  before_action :set_spot, only: %i[show edit update destroy move]

  # GET /trips/:trip_id/spots/1
  def show
    authorize @spot
  end

  # GET /trips/:trip_id/spots/new
  def new
    # スポット追加画面ではヘッダーを非表示（以前の修正）
    @hide_header = true
    @spot = @trip.spots.build
    authorize @spot
  end

  # GET /trips/:trip_id/spots/1/edit
  def edit
    authorize @spot
  end

  # POST /trips/:trip_id/spots
  def create
    @spot = @trip.spots.build(spot_params)
    authorize @spot

    # リダイレクト先を決定: source パラメータが 'chat' から送られてきた場合にのみチャット画面に戻る
    redirect_destination = if params[:spot][:source] == 'chat'
                           trip_messages_path(@trip)
                         else
                           # 通常のスポット追加フォームからの場合は、詳細画面に戻る
                           @trip 
                         end
                         
    if @spot.save
      # ★スポット保存後に移動時間計算を呼び出す
      calculate_and_update_travel_time(@spot)
      
      # ★リダイレクト先を分岐で決定
      flash[:notice] = "「#{@spot.name}」を旅程のDay #{@spot.day_number}に追加しました。"
      redirect_to redirect_destination
    else
      # 失敗した場合も、リダイレクト先に戻す
      flash[:alert] = "スポットの追加に失敗しました: #{@spot.errors.full_messages.join(', ')}"
      redirect_to redirect_destination
    end
  end

  # PATCH/PUT /trips/:trip_id/spots/1
  def update
    authorize @spot
    
    if @spot.update(spot_params)
      # 更新後の移動時間再計算は複雑なため、今回はスキップ（必要に応じて追加）
      
      redirect_to @trip, notice: t('messages.spot.update_success')
    else
      flash.now[:alert] = t('messages.spot.update_failure')
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /trips/:trip_id/spots/1
  def destroy
    authorize @spot
    
    @spot.destroy!
    # 削除後の移動時間再計算は複雑なため、スキップ
    redirect_to @trip, notice: t('messages.spot.delete_success'), status: :see_other
  end
  
  # PATCH /trips/:trip_id/spots/:id/move
  def move
    authorize @spot
    
    @spot.insert_at(params[:position].to_i)
    # 移動後の移動時間再計算はスキップ
    head :ok
  end


  private
    def set_trip
      @trip = Trip.find(params[:trip_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: t('messages.trip.not_found_simple')
    end

    def set_spot
      @spot = @trip.spots.find(params[:id])
    end

    def spot_params
      # ★修正箇所: latitude, longitude, source を許可リストに追加
      params.require(:spot).permit(
        :name, 
        :description, 
        :address, 
        :category, 
        :estimated_cost, 
        :duration, 
        :travel_time, 
        :day_number, 
        :position, 
        :latitude,  
        :longitude,
        :source # リダイレクト先分岐用のパラメータ
      )
    end
    
    # ★ 移動時間計算と保存のためのプライベートメソッド ★
    def calculate_and_update_travel_time(new_spot)
      # 1. 旅程内で、新しいスポットの直前に位置するスポットを取得 (出発地)
      previous_spot = @trip.spots.order(:position).where('position < ?', new_spot.position).last
      
      # 2. 最初のスポットではない & 緯度経度データが揃っているか確認
      if previous_spot.present? && 
         new_spot.latitude.present? && new_spot.longitude.present? && 
         previous_spot.latitude.present? && previous_spot.longitude.present?
        
        begin
          api_key = Rails.application.credentials.google_maps[:api_key]
          
          # 緯度経度の参照
          origin      = "#{previous_spot.latitude},#{previous_spot.longitude}"
          destination = "#{new_spot.latitude},#{new_spot.longitude}"
          
          base_url = "https://maps.googleapis.com/maps/api/directions/json"
          
          params = {
            origin: origin,
            destination: destination,
            key: api_key,
            mode: 'driving'
          }

          uri = URI(base_url)
          uri.query = URI.encode_www_form(params)

          # HTTPリクエストの実行
          response = Net::HTTP.get_response(uri)
          data = JSON.parse(response.body)

          travel_time_in_minutes = nil
          
          if data['status'] == 'OK' && data['routes'].present?
            # 応答から移動時間(秒)を取得し、分に変換
            duration_in_seconds = data['routes'][0]['legs'][0]['duration']['value'].to_i
            travel_time_in_minutes = (duration_in_seconds / 60.0).round.to_i 
          elsif data['error_message'].present?
            # APIからのエラーメッセージをログに出力
            Rails.logger.error "Google Maps API Error (Status: #{data['status']}): #{data['error_message']}"
          end

          # 3. 計算結果を、出発地となる前のスポットの travel_time カラムに保存する
          if travel_time_in_minutes.present?
            previous_spot.update!(travel_time: travel_time_in_minutes)
          end
          
        rescue => e
          # ネットワークやパースのエラー
          Rails.logger.error "Google Maps API/Network Error: #{e.message}"
        end
      end
    end
end