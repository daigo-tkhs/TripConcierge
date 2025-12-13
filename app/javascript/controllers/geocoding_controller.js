// app/javascript/controllers/geocoding_controller.js

import { Controller } from "@hotwired/stimulus"
import debounce from "debounce"

export default class extends Controller {
  // StimulusJS Targets
  static targets = [ "address", "latitude", "longitude"]
  
  // Google Maps API Key from data attribute
  static values = { apiKey: String }

  // app/javascript/controllers/geocoding_controller.js (connectメソッドのみ抜粋)
  connect() {
    console.log("Geocoding Controller connected.")
    this.geocodeDebounced = debounce(this.geocode, 800)
  }

  // ジオコーディングを実行し、緯度経度を取得する
  geocode() {
    const address = this.addressTarget.value
    if (address.length < 5) {
      this.clearCoords()
      return
    }

    // Geocoding APIのエンドポイント
    const url = `https://maps.googleapis.com/maps/api/geocode/json?address=${encodeURIComponent(address)}&key=${this.apiKeyValue}`

    fetch(url)
      .then(response => response.json())
      .then(data => {
        if (data.status === 'OK') {
          const location = data.results[0].geometry.location
          this.latitudeTarget.value = location.lat
          this.longitudeTarget.value = location.lng
        } else if (data.status === 'ZERO_RESULTS') {
          this.clearCoords()
        } else {
          this.clearCoords()
        }
      })
      .catch(error => {
        console.error('Geocoding API Error:', error)
        this.clearCoords()
      })
  }
  
  // 緯度経度フィールドをクリアする
  clearCoords() {
    this.latitudeTarget.value = ''
    this.longitudeTarget.value = ''
  }

}