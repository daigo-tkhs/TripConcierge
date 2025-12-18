import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    apiKey: String,
    markers: Array
  }

  initialize() {
    // Google Maps APIが呼ぶグローバル関数を、このインスタンスのメソッドに紐付ける
    window.mapControllerInit = this.initMap.bind(this)
  }

  connect() {
    // もしAPIが既に読み込まれていた場合のためにチェック
    if (window.google && window.google.maps) {
      this.initMap()
    }
  }

  initMap() {
    // コンテナターゲットがなかったり、地図が既に初期化されていたら何もしない
    if (!this.hasContainerTarget || this.map) return

    const mapOptions = {
      center: { lat: 35.6812, lng: 139.7671 }, // デフォルトは東京駅
      zoom: 12,
      mapTypeControl: false,
      streetViewControl: false,
      fullscreenControl: false
    }

    this.map = new google.maps.Map(this.containerTarget, mapOptions)
    this.addMarkers()
  }

  addMarkers() {
    if (!this.markersValue || this.markersValue.length === 0) return

    const bounds = new google.maps.LatLngBounds()

    this.markersValue.forEach(markerData => {
      const position = { lat: parseFloat(markerData.lat), lng: parseFloat(markerData.lng) }
      
      new google.maps.Marker({
        position: position,
        map: this.map,
        title: markerData.title
      })

      bounds.extend(position)
    })

    // 全てのマーカーが見えるように調整
    this.map.fitBounds(bounds)
    
    // マーカーが1つだけの場合、ズームが寄りすぎるのを防ぐ
    if (this.markersValue.length === 1) {
      google.maps.event.addListenerOnce(this.map, 'bounds_changed', () => {
        this.map.setZoom(15)
      })
    }
  }

  disconnect() {
    // ページ遷移時にグローバル関数をクリーンアップ
    window.mapControllerInit = null
  }
}