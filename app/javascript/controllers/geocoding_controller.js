import { Controller } from "@hotwired/stimulus"
import debounce from "debounce"

export default class extends Controller {
  static targets = [ "address", "latitude", "longitude", "submit" ] 
  static values = { apiKey: String }

  connect() {
    this.geocodeDebounced = debounce(this.geocode, 800)
    this.loadGoogleMaps()
    this.toggleSubmitButton()
  }

  loadGoogleMaps() {
    // マーカー機能(marker)まで読み込まれているかチェック
    if (window.google && window.google.maps && window.google.maps.marker) return

    const existingScript = document.querySelector(`script[src*="maps.googleapis.com/maps/api/js"]`)
    // 既存スクリプトがあっても、markerが含まれていないURLなら無視して読み込み直す判定が必要だが
    // 今回は重複を避けるため、既存があれば一旦任せる（ただしGeocodingが先に走るとMapが失敗するリスクはある）
    if (existingScript) return

    const script = document.createElement("script")
    // ▼▼▼ Mapコントローラーと完全に一致させる (libraries=places,marker) ▼▼▼
    script.src = `https://maps.googleapis.com/maps/api/js?key=${this.apiKeyValue}&libraries=places,marker&v=weekly`
    script.async = true
    script.defer = true
    document.head.appendChild(script)
  }

  async geocode() {
    const address = this.addressTarget.value
    this.toggleSubmitButton(false)

    if (address.length < 2) {
      this.clearCoords()
      return
    }

    if (!window.google || !window.google.maps) return

    const geocoder = new google.maps.Geocoder()

    try {
      const result = await geocoder.geocode({ address: address })
      
      if (result.results && result.results.length > 0) {
        const location = result.results[0].geometry.location
        this.latitudeTarget.value = location.lat()
        this.longitudeTarget.value = location.lng()
      } else {
        this.clearCoords()
      }
    } catch (error) {
      console.error("Geocoding failed:", error)
      this.clearCoords()
    } finally {
      this.toggleSubmitButton()
    }
  }
  
  clearCoords() {
    this.latitudeTarget.value = ''
    this.longitudeTarget.value = ''
    this.toggleSubmitButton()
  }

  toggleSubmitButton(forceState = null) {
    if (!this.hasSubmitTarget) return
    const coordsPresent = this.latitudeTarget.value && this.longitudeTarget.value
    let isEnabled = forceState !== null ? forceState : coordsPresent

    this.submitTarget.disabled = !isEnabled
    if (isEnabled) {
      this.submitTarget.classList.remove('opacity-50', 'cursor-not-allowed')
      this.submitTarget.classList.add('cursor-pointer')
    } else {
      this.submitTarget.classList.add('opacity-50', 'cursor-not-allowed')
      this.submitTarget.classList.remove('cursor-pointer')
    }
  }
}