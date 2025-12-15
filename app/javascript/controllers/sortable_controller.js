// app/javascript/controllers/sortable_controller.js

import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.sortable = Sortable.create(this.element, {
      group: 'shared-spots',
      animation: 150,
      handle: ".cursor-move",
      onEnd: this.end.bind(this)
    })
  }

  end(event) {
    const id = event.item.dataset.id
    const newIndex = event.newIndex + 1
    const newDayNumber = event.to.dataset.dayNumber

    fetch(this.urlValue.replace(":id", id), {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ 
        position: newIndex,
        day_number: newDayNumber
      })
    }) 
    .then(response => {
      // サーバー応答後に強制リロード
      if (response.ok) {
        window.location.reload()
      } else {
        console.error('スポットの並び替えに失敗しました。');
      }
    })
    .catch(error => {
      console.error('通信エラー:', error);
    });
  }
}