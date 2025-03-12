import { Controller } from "@hotwired/stimulus"

// 説明文自動生成用のStimulusコントローラー
export default class extends Controller {
  static targets = ["description"]

  connect() {
    console.log("Description generator controller connected")
  }

  // 説明文を自動生成する処理
  async generateDescription(event) {
    event.preventDefault()

    // URLとタイトルの入力値を取得
    const urlInput = document.getElementById("prompt_url")
    const titleInput = document.getElementById("prompt_title")
    const descriptionInput = this.descriptionTarget

    if (!urlInput || !urlInput.value) {
      alert("URLを入力してください")
      return
    }

    // ボタンの状態を更新
    const button = event.currentTarget
    const originalContent = button.innerHTML
    button.innerHTML = '<i class="bi bi-hourglass-split"></i> 生成中...'
    button.disabled = true

    try {
      // APIリクエストを送信
      const response = await fetch(`/prompts/generate_description?url=${encodeURIComponent(urlInput.value)}&title=${encodeURIComponent(titleInput.value || '')}`)

      if (!response.ok) {
        throw new Error("APIリクエストに失敗しました")
      }

      const data = await response.json()

      // 説明文を入力欄に設定
      if (data.description) {
        descriptionInput.value = data.description
      }
    } catch (error) {
      console.error("説明文の生成に失敗しました:", error)
      alert("説明文の生成に失敗しました。もう一度お試しください。")
    } finally {
      // ボタンの状態を元に戻す
      button.innerHTML = originalContent
      button.disabled = false
    }
  }
}