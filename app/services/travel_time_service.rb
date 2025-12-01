class TravelTimeService
  def initialize
    @client = GoogleMapsService::Client.new(
      key: Rails.application.credentials.google_maps[:api_key],
      retry_timeout: 20,
      queries_per_second: 10
    )
  end

  # 2地点間の移動時間を計算（単位: 分）
  def calculate_time(origin_spot, destination_spot)
    # 緯度経度がない場合は計算不可
    return nil unless origin_spot.geocoded? && destination_spot.geocoded?

    # Google Maps Directions APIを叩く
    routes = @client.directions(
      "#{origin_spot.latitude},#{origin_spot.longitude}",
      "#{destination_spot.latitude},#{destination_spot.longitude}",
      mode: "driving", # 車での移動（必要に応じて walking 等に変更可）
      language: "ja"
    )

    return nil if routes.empty?

    # 所要時間（秒）を取得し、分に変換（四捨五入）
    duration_seconds = routes[0][:legs][0][:duration][:value]
    (duration_seconds / 60.0).round
  rescue => e
    Rails.logger.error "TravelTimeService Error: #{e.message}"
    nil
  end
end