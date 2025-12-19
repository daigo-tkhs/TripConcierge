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
    // 既に読み込まれており、かつ importLibrary が使えるか確認
    if (window.google && window.google.maps && window.google.maps.importLibrary) {
      this.initMap()
      return
    }

    const existingScript = document.querySelector(`script[src*="maps.googleapis.com/maps/api/js"]`)
    if (existingScript) {
      existingScript.addEventListener("load", () => this.initMap())
      return
    }

    const script = document.createElement("script")
    // v=weekly と libraries=places を指定。loading=async も付与してパフォーマンス最適化
    script.src = `https://maps.googleapis.com/maps/api/js?key=${this.apiKeyValue}&libraries=places&v=weekly&loading=async`
    script.async = true
    script.defer = true
    script.onload = () => this.initMap()
    document.head.appendChild(script)
  }

  async initMap() {
    if (!this.hasContainerTarget) return

    try {
      // 最新のライブラリを明示的に読み込む（これがズレを防ぐ鍵です）
      const { Map } = await google.maps.importLibrary("maps")
      const { AdvancedMarkerElement, PinElement } = await google.maps.importLibrary("marker")

      const mapOptions = {
        center: { lat: 35.6812, lng: 139.7671 },
        zoom: 12,
        mapId: "DEMO_MAP_ID", // 青いピン（AdvancedMarker）の使用に必須
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: false
      }

      this.map = new Map(this.containerTarget, mapOptions)
      
      // マーカーと写真を読み込む
      this.addMarkers(AdvancedMarkerElement, PinElement)
      this.loadSpotPhotos()

    } catch (error) {
      console.error("Error initializing Google Maps:", error)
    }
  }

  addMarkers(AdvancedMarkerElement, PinElement) {
    if (!this.markersValue || this.markersValue.length === 0) return

    const bounds = new google.maps.LatLngBounds()

    this.markersValue.forEach((markerData, index) => {
      const position = { lat: parseFloat(markerData.lat), lng: parseFloat(markerData.lng) }
      
      // 正確で青いピン（AdvancedMarker）を作成
      const pin = new PinElement({
        glyphText: `${index + 1}`, // glyph ではなく glyphText を使用してエラー回避
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
      google.maps.event.addListenerOnce(this.map, "idle", () => {
        this.map.setZoom(15)
      })
    }
  }

  loadSpotPhotos() {
    if (!this.hasSpotImageTarget) return

    // Placesライブラリを使用して写真を検索
    const service = new google.maps.places.PlacesService(this.map)

    this.spotImageTargets.forEach(target => {
      const spotName = target.dataset.spotName
      if (!spotName) return

      const request = {
        query: spotName,
        fields: ['photos'] 
      }

      service.findPlaceFromQuery(request, (results, status) => {
        if (status === google.maps.places.PlacesServiceStatus.OK && results && results[0].photos) {
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