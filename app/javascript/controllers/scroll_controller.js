import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Turboのスクロールリセットと競合しないよう、わずかに遅らせて実行
    setTimeout(() => {
      this.scrollToBottom()
    }, 100)

    // メッセージの追加や変更を監視してスクロール
    this.observer = new MutationObserver(() => {
      this.scrollToBottom()
    })
    
    this.observer.observe(this.element, {
      childList: true,
      subtree: true
    })
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  scrollToBottom() {
    const anchor = document.getElementById("scroll-anchor")

    if (anchor) {
      // 強制的にアンカーの位置へスクロール
      anchor.scrollIntoView({ block: "end", behavior: "instant" })
    } else {
      this.element.scrollTop = this.element.scrollHeight
    }
  }
}