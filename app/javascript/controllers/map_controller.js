// app/javascript/controllers/map_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "spotImage"]
  static values = {
    apiKey: String,
    markers: Array
  }

  connect() {
    this.loadGoogleMaps()
  }

  loadGoogleMaps() {
    // 既に読み込まれていれば初期化へ
    if (window.google && window.google.maps) {
      this.initMap()
      return
    }

    // 既存のスクリプトタグがあれば待機
    const existingScript = document.querySelector(`script[src*="maps.googleapis.com/maps/api/js"]`)
    if (existingScript) {
      existingScript.addEventListener("load", () => this.initMap())
      return
    }

    // スクリプトを読み込む (importLibraryは使わず、クラシックな読み込み方)
    const script = document.createElement("script")
    // libraries=places のみを指定 (markerは標準に含まれる)
    script.src = `https://maps.googleapis.com/maps/api/js?key=${this.apiKeyValue}&libraries=places`
    script.async = true
    script.defer = true
    script.onload = () => this.initMap()
    document.head.appendChild(script)
  }

  initMap() {
    if (!this.hasContainerTarget) return

    // ▼▼▼ 修正: importLibrary を使わず、new google.maps.Map を使う (安定版) ▼▼▼
    const mapOptions = {
      center: { lat: 35.6812, lng: 139.7671 },
      zoom: 12,
      mapTypeControl: false,
      streetViewControl: false,
      fullscreenControl: false
    }

    this.map = new google.maps.Map(this.containerTarget, mapOptions)
    
    this.addMarkers()
    this.loadSpotPhotos()
  }

  addMarkers() {
    if (!this.markersValue || this.markersValue.length === 0) return

    const bounds = new google.maps.LatLngBounds()

    this.markersValue.forEach((markerData, index) => {
      const position = { lat: parseFloat(markerData.lat), lng: parseFloat(markerData.lng) }
      
      // ▼▼▼ 修正: 標準の Marker を使用 (AdvancedMarkerElementはやめる) ▼▼▼
      // これにより glyph のエラーも解消されます
      new google.maps.Marker({
        position: position,
        map: this.map,
        title: markerData.title,
        label: {
          text: `${index + 1}`,
          color: "white",
          fontWeight: "bold"
        }
      })

      bounds.extend(position)
    })

    this.map.fitBounds(bounds)
    
    if (this.markersValue.length === 1) {
      const listener = google.maps.event.addListener(this.map, "idle", () => { 
        this.map.setZoom(15) 
        google.maps.event.removeListener(listener)
      })
    }
  }

  loadSpotPhotos() {
    if (!this.hasSpotImageTarget) return

    // ▼▼▼ 修正: PlacesService もクラシックな書き方で初期化 ▼▼▼
    const service = new google.maps.places.PlacesService(this.map)

    this.spotImageTargets.forEach(target => {
      const spotName = target.dataset.spotName
      if (!spotName) return

      const request = {
        query: spotName,
        fields: ['photos'] 
      }

      service.findPlaceFromQuery(request, (results, status) => {
        // ステータスコードのチェックもクラシックな書き方で
        if (status === google.maps.places.PlacesServiceStatus.OK && results && results.length > 0 && results[0].photos) {
          // 写真URLを取得 (最大幅400px)
          const photoUrl = results[0].photos[0].getUrl({ maxWidth: 400 })
          this.injectPhoto(target, photoUrl)
        }
      })
    })
  }

  injectPhoto(targetElement, url) {
    const img = document.createElement('img')
    img.src = url
    img.className = "w-full h-full object-cover transition-opacity duration-500 opacity-0"
    img.onload = () => img.classList.remove('opacity-0')
    targetElement.innerHTML = ''
    targetElement.appendChild(img)
  }
}