import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"] 
  static values = { apiKey: String, markers: Array }

  connect() {
    this.loadGoogleMaps()
  }

  loadGoogleMaps() {
    // 既に読み込まれていて、かつマーカー機能(marker)も存在するかチェック
    if (window.google && window.google.maps && window.google.maps.marker) {
      this.initMap()
      return
    }

    const script = document.createElement("script")
    // v=weekly (安定版) を指定
    script.src = `https://maps.googleapis.com/maps/api/js?key=${this.apiKeyValue}&libraries=places,marker&v=weekly`
    script.async = true
    script.defer = true
    script.onload = () => this.initMap()
    document.head.appendChild(script)
  }

  initMap() {
    if (!this.hasContainerTarget) return

    if (!google.maps.marker) {
      console.error("Marker library not loaded.")
      return
    }

    const mapOptions = {
      center: { lat: 35.6812, lng: 139.7671 },
      zoom: 12,
      mapId: "DEMO_MAP_ID",
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
    
    // 表示範囲を管理するオブジェクト
    const bounds = new google.maps.LatLngBounds()
    const { AdvancedMarkerElement, PinElement } = google.maps.marker

    this.markersValue.forEach((markerData, index) => {
      const lat = parseFloat(markerData.lat)
      const lng = parseFloat(markerData.lng)
      
      // 座標が不正な場合はスキップ
      if (isNaN(lat) || isNaN(lng)) return

      const position = { lat: lat, lng: lng }
      
      const pin = new PinElement({
        glyphText: `${index + 1}`,
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

      // この座標を範囲に含める
      bounds.extend(position)
    })

    // 全てのピンが見えるように地図をズーム・移動
    this.map.fitBounds(bounds)

    // ピンが1つだけの場合、fitBoundsだとズームしすぎるので調整
    if (this.markersValue.length === 1) {
      const listener = google.maps.event.addListener(this.map, "idle", () => {
        this.map.setZoom(15)
        google.maps.event.removeListener(listener)
      })
    }
  }

  // ▼▼▼ ここを「Places API (New)」の書き方に完全リニューアル ▼▼▼
  async loadSpotPhotos() {
    const targets = document.querySelectorAll('[data-map-target="spotImage"]')
    if (targets.length === 0) return

    // 最新の Places ライブラリを読み込みます
    // ※ importLibraryは非同期なので await が必要ですが、このメソッド自体が async なのでOK
    let Place;
    try {
        const lib = await google.maps.importLibrary("places");
        Place = lib.Place;
    } catch (e) {
        console.error("Places library import failed:", e);
        return;
    }

    targets.forEach(async (target) => {
      const spotName = target.dataset.spotName
      if (!spotName) return

      try {
        // 【重要】新しい「テキスト検索（New）」を使用
        // searchByText は Promise を返すので await で待ちます
        const { places } = await Place.searchByText({
            textQuery: spotName,
            fields: ['photos'], // 必要なフィールドのみ指定（節約）
            maxResultCount: 1,  // 1件だけ取得
        });

        if (places && places.length > 0 && places[0].photos && places[0].photos.length > 0) {
            const photo = places[0].photos[0];
            // 新しいAPIでは getUrl() ではなく getURI() を使う場合がありますが
            // 最新のJS SDKでは getURI() が推奨されています
            const photoUrl = photo.getURI({ maxWidth: 400 });
            this.injectPhoto(target, photoUrl);
        }
      } catch (error) {
        console.warn(`Photo fetch failed for ${spotName}:`, error);
      }
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