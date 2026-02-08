import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "button"]

  submit() {
    const text = this.inputTarget.value.trim()
    if (!text) return

    const messagesContainer = document.getElementById("messages")
    if (messagesContainer) {
      const thinkingEl = document.createElement("div")
      thinkingEl.id = "ai-thinking-indicator"
      thinkingEl.className = "flex justify-start items-start gap-3 mb-6"
      thinkingEl.innerHTML = `
        <div class="w-10 h-10 rounded-full bg-purple-100 flex-shrink-0 border border-purple-200 shadow-sm flex items-center justify-center">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-5 h-5 text-purple-500">
            <path d="M10 2a.75.75 0 0 1 .75.75v1.5a.75.75 0 0 1-1.5 0v-1.5A.75.75 0 0 1 10 2ZM10 15a.75.75 0 0 1 .75.75v1.5a.75.75 0 0 1-1.5 0v-1.5A.75.75 0 0 1 10 15ZM10 7a3 3 0 1 0 0 6 3 3 0 0 0 0-6ZM15.657 5.404a.75.75 0 1 0-1.06-1.06l-1.061 1.06a.75.75 0 0 0 1.06 1.061l1.06-1.06ZM6.464 14.596a.75.75 0 1 0-1.06-1.06l-1.061 1.06a.75.75 0 0 0 1.06 1.061l1.06-1.06ZM18 10a.75.75 0 0 1-.75.75h-1.5a.75.75 0 0 1 0-1.5h1.5A.75.75 0 0 1 18 10ZM5 10a.75.75 0 0 1-.75.75h-1.5a.75.75 0 0 1 0-1.5h1.5A.75.75 0 0 1 5 10ZM14.596 15.657a.75.75 0 0 0 1.06-1.06l-1.06-1.061a.75.75 0 1 0-1.061 1.06l1.06 1.061ZM5.404 6.464a.75.75 0 0 0 1.06-1.06l-1.06-1.061a.75.75 0 1 0-1.061 1.06l1.06 1.061Z" />
          </svg>
        </div>
        <div class="bg-white p-4 rounded-2xl rounded-tl-none border border-gray-100 shadow-sm">
          <p class="text-xs font-bold text-purple-600 mb-2">AI Concierge</p>
          <div class="flex items-center gap-3">
            <div class="flex gap-1.5">
              <span class="w-2 h-2 bg-purple-400 rounded-full animate-bounce" style="animation-delay: 0s"></span>
              <span class="w-2 h-2 bg-purple-400 rounded-full animate-bounce" style="animation-delay: 0.15s"></span>
              <span class="w-2 h-2 bg-purple-400 rounded-full animate-bounce" style="animation-delay: 0.3s"></span>
            </div>
            <span class="text-sm text-gray-500">考え中...</span>
          </div>
        </div>
      `
      messagesContainer.appendChild(thinkingEl)

      const anchor = document.getElementById("scroll-anchor")
      if (anchor) anchor.scrollIntoView({ behavior: "smooth" })
    }

    this.inputTarget.disabled = true
    this.buttonTarget.disabled = true
    this.buttonTarget.classList.add("opacity-50")
  }
}
