import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Connects to data-controller="sortable"
export default class extends Controller {
  // リクエスト送信先のURLを受け取る設定
  static values = { url: String }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: ".cursor-move", // ドラッグできるハンドル（今回はカード全体にするので後でクラスを調整）
      onEnd: this.end.bind(this)
    })
  }

  // ドラッグ終了時に呼ばれる
  end(event) {
    const id = event.item.dataset.id
    const newIndex = event.newIndex + 1 // acts_as_listは1始まり

    // サーバーにPatchリクエストを送信
    fetch(this.urlValue.replace(":id", id), {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ position: newIndex })
    })
  }
}