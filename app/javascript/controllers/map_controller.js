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
    if (window.google && window.google.maps) {
      this.initMap()
      return
    }

    const script = document.createElement("script")
    // libraries=places,marker を指定し、v=beta（最新機能用）を指定します
    script.src = `https://maps.googleapis.com/maps/api/js?key=${this.apiKeyValue}&libraries=places,marker&v=beta`
    script.async = true
    script.defer = true
    script.onload = () => this.initMap()
    document.head.appendChild(script)
  }

  initMap() {
    if (!this.hasContainerTarget) return

    // importLibrary を使わず、直接クラスを参照します
    // これにより "is not a function" エラーを確実に回避します
    const mapOptions = {
      center: { lat: 35.6812, lng: 139.7671 },
      zoom: 12,
      mapId: "DEMO_MAP_ID", // 青いピン(AdvancedMarker)に必須
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
      
      // AdvancedMarkerElement を直接 new します
      const pin = new google.maps.marker.PinElement({
        glyphText: `${index + 1}`,
        background: "#2563EB",
        borderColor: "#1E40AF",
        glyphColor: "white",
      })

      new google.maps.marker.AdvancedMarkerElement({
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