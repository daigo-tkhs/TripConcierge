// app/javascript/controllers/file_preview_controller.js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="file-preview"
export default class extends Controller {
  static targets = ["input", "previewContainer"]

  preview(event) {
    const input = this.inputTarget
    const container = this.previewContainerTarget

    // 既存のプレビューをクリア
    container.innerHTML = ''

    if (input.files && input.files[0]) {
      const reader = new FileReader()

      reader.onload = function(e) {
        // 画像エレメントを作成
        const img = document.createElement('img')
        img.src = e.target.result
        img.className = 'w-full sm:w-64 h-auto rounded-lg shadow-md border border-gray-200 object-cover'

        // コンテナに追加
        container.appendChild(img)
      }

      reader.readAsDataURL(input.files[0])
    } else {
      // ファイルが選択されていない場合はプレースホルダーを再表示
      container.innerHTML = `
        <div class="w-full sm:w-64 h-40 bg-gray-100 rounded-lg shadow-sm border border-dashed border-gray-300 flex items-center justify-center text-gray-400 text-sm">
          画像なし
        </div>
      `
    }
  }
}