// app/javascript/controllers/map_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // spotImage ターゲットを追加（リスト上の写真枠）
  static targets = ["container", "spotImage"]
  static values = {
    apiKey: String,
    markers: Array
  }

  connect() {
    this.loadGoogleMaps()
  }

  loadGoogleMaps() {
    if (window.google && window.google.maps) {
      this.initMap()
      return
    }

    const existingScript = document.querySelector(`script[src*="maps.googleapis.com/maps/api/js"]`)
    if (existingScript) {
      existingScript.addEventListener("load", () => this.initMap())
      return
    }

    const script = document.createElement("script")
    // Placesライブラリが必要なので libraries=places,marker を指定
    script.src = `https://maps.googleapis.com/maps/api/js?key=${this.apiKeyValue}&libraries=places,marker&loading=async&v=weekly`
    script.async = true
    script.defer = true
    script.onload = () => this.initMap()
    document.head.appendChild(script)
  }

  async initMap() {
    if (!this.hasContainerTarget) return

    const { Map } = await google.maps.importLibrary("maps")
    const { AdvancedMarkerElement, PinElement } = await google.maps.importLibrary("marker")

    // マップ初期化
    const mapOptions = {
      center: { lat: 35.6812, lng: 139.7671 },
      zoom: 12,
      mapId: "DEMO_MAP_ID",
      mapTypeControl: false,
      streetViewControl: false,
      fullscreenControl: false
    }

    this.map = new Map(this.containerTarget, mapOptions)
    
    // マーカー追加
    this.addMarkers(AdvancedMarkerElement, PinElement)
    
    // ▼▼▼ 写真取得の開始 ▼▼▼
    this.loadSpotPhotos()
  }

  addMarkers(AdvancedMarkerElement, PinElement) {
    if (!this.markersValue || this.markersValue.length === 0) return

    const bounds = new google.maps.LatLngBounds()

    this.markersValue.forEach((markerData, index) => {
      const position = { lat: parseFloat(markerData.lat), lng: parseFloat(markerData.lng) }
      
      const pin = new PinElement({
        glyph: `${index + 1}`,
        background: "#2563EB",
        borderColor: "#1E40AF",
        glyphColor: "white",
      })

      new AdvancedMarkerElement({
        position: position,
        map: this.map,
        title: markerData.title,
        content: pin.element
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

  // --- ▼▼▼ 写真取得機能 ▼▼▼ ---
  loadSpotPhotos() {
    if (!this.hasSpotImageTarget) return

    // PlacesService を使うにはマップのインスタンスが必要
    const service = new google.maps.places.PlacesService(this.map)

    this.spotImageTargets.forEach(target => {
      // HTML側で設定したデータ属性からスポット名を取得
      const spotName = target.dataset.spotName
      if (!spotName) return

      const request = {
        query: spotName,
        fields: ['photos'] // 写真のみ要求（コスト節約）
      }

      // Google Places API で検索
      service.findPlaceFromQuery(request, (results, status) => {
        if (status === google.maps.places.PlacesServiceStatus.OK && results && results.length > 0 && results[0].photos) {
          // 写真URLを取得 (最大幅400px)
          const photoUrl = results[0].photos[0].getUrl({ maxWidth: 400 })
          this.injectPhoto(target, photoUrl)
        }
      })
    })
  }

  injectPhoto(targetElement, url) {
    // 画像タグを作成
    const img = document.createElement('img')
    img.src = url
    img.className = "w-full h-full object-cover transition-opacity duration-500 opacity-0"
    
    // 読み込み完了後にフェードイン
    img.onload = () => img.classList.remove('opacity-0')
    
    // 既存のアイコン（灰色）をクリアして画像を追加
    targetElement.innerHTML = ''
    targetElement.appendChild(img)
  }
}