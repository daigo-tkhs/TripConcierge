// app/javascript/controllers/index.js

// 1. application.js から application オブジェクトをインポート
import { application } from "controllers/application"

// 2. Stimulus Loadingを使った自動読み込み設定をコメントアウトし、手動で登録する
// import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
// eagerLoadControllersFrom("controllers", application) 

// --- 3. 手動登録 ---

// geocoding_controller.js を登録
import GeocodingController from "./geocoding_controller" 
application.register("geocoding", GeocodingController)

// ★必要に応じて、その他の既存コントローラーもここに手動で追加してください★
// 例:
// import MapController from "./map_controller" 
// application.register("map", MapController) 

// import HelloController from "./hello_controller"
// application.register("hello", HelloController)

// ----------------------