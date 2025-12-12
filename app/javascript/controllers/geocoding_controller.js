// app/javascript/controllers/geocoding_controller.js

import { Controller } from "@hotwired/stimulus"
import debounce from "debounce"

export default class extends Controller {
  // StimulusJS Targets
  static targets = [ "address", "latitude", "longitude", "status" ]
  
  // Google Maps API Key from data attribute
  static values = { apiKey: String }

  // app/javascript/controllers/geocoding_controller.js (connectメソッドのみ抜粋)
  connect() {
    console.log("Geocoding Controller connected.")
    this.geocodeDebounced = debounce(this.geocode, 800)
    this.updateStatus()
  }

  // ジオコーディングを実行し、緯度経度を取得する
  geocode() {
    const address = this.addressTarget.value
    if (address.length < 5) {
      this.clearCoords()
      return
    }

    this.statusTarget.textContent = '位置情報を検索中...'

    // Geocoding APIのエンドポイント
    const url = `https://maps.googleapis.com/maps/api/geocode/json?address=${encodeURIComponent(address)}&key=${this.apiKeyValue}`

    fetch(url)
      .then(response => response.json())
      .then(data => {
        if (data.status === 'OK') {
          const location = data.results[0].geometry.location
          this.latitudeTarget.value = location.lat
          this.longitudeTarget.value = location.lng
          this.updateStatus(true)
        } else if (data.status === 'ZERO_RESULTS') {
          this.clearCoords()
          this.statusTarget.textContent = '⚠ 位置が見つかりませんでした。より詳細な住所を入力してください。'
          this.statusTarget.classList.add('text-red-600')
          this.statusTarget.classList.remove('text-green-600')
        } else {
          this.clearCoords()
          this.statusTarget.textContent = `エラー: ${data.status}`
          this.statusTarget.classList.add('text-red-600')
          this.statusTarget.classList.remove('text-green-600')
        }
      })
      .catch(error => {
        console.error('Geocoding API Error:', error)
        this.clearCoords()
        this.statusTarget.textContent = '通信エラーが発生しました。'
        this.statusTarget.classList.add('text-red-600')
        this.statusTarget.classList.remove('text-green-600')
      })
  }
  
  // 緯度経度フィールドをクリアする
  clearCoords() {
    this.latitudeTarget.value = ''
    this.longitudeTarget.value = ''
    this.updateStatus()
  }

  // ステータス表示を更新する
  updateStatus(success = false) {
    if (this.latitudeTarget.value && this.longitudeTarget.value) {
      this.statusTarget.textContent = `✅ 位置情報取得済み: Lat/Lng (${parseFloat(this.latitudeTarget.value).toFixed(4)}, ${parseFloat(this.longitudeTarget.value).toFixed(4)})`
      this.statusTarget.classList.add('text-green-600')
      this.statusTarget.classList.remove('text-red-600')
    } else if (success === true) {
       // 成功したが値がない場合はクリア (基本的にありえないが)
       this.statusTarget.textContent = ''
    } else {
       // 初期状態またはクリアされた状態
       this.statusTarget.textContent = ''
       this.statusTarget.classList.remove('text-red-600', 'text-green-600')
    }
  }
}