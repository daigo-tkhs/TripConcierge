# frozen_string_literal: true

require 'net/http'

class TravelTimeService
  BASE_URL = 'https://maps.googleapis.com/maps/api/directions/json'

  def initialize
    # APIキーはcredentialsから読み込む
    @api_key = Rails.application.credentials.google_maps[:api_key]
  end

  # Metrics指摘を解消するため、ロジックを分割
  def calculate_time(origin_spot, destination_spot)
    return 0 unless origin_spot&.geocoded? && destination_spot&.geocoded?

    uri = build_uri(origin_spot, destination_spot)

    # 1. APIリクエスト実行
    response = execute_request(uri)

    # 2. 結果のパースと時間抽出
    parse_response(response)
  rescue StandardError => e
    Rails.logger.error "Google Maps API Error for travel time: #{e.message}"
    0 # エラー時は移動時間0分として扱う
  end

  private

  # 1. URIの構築を分離
  def build_uri(origin_spot, destination_spot)
    params = {
      origin: "#{origin_spot.latitude},#{origin_spot.longitude}",
      destination: "#{destination_spot.latitude},#{destination_spot.longitude}",
      mode: 'driving', # 車での移動時間を取得
      key: @api_key
    }
    URI.parse("#{BASE_URL}?#{URI.encode_www_form(params)}")
  end

  # 2. HTTPリクエストの実行を分離
  def execute_request(uri)
    response = Net::HTTP.get_response(uri)
    raise "HTTP Error: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    response.body
  end

  # 3. JSONパースと時間抽出を分離
  def parse_response(response_body)
    data = JSON.parse(response_body)

    # ルートが見つからない、またはステータスが異常な場合
    if data['status'] != 'OK' || data['routes'].empty?
      Rails.logger.warn "Maps API returned status: #{data['status']}. Routes not found."
      return 0
    end

    # 経路情報から移動時間(秒)を取得し、分に変換
    duration_seconds = data['routes'][0]['legs'][0]['duration']['value']
    (duration_seconds.to_f / 60).round
  end
end
