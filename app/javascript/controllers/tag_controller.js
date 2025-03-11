import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    name: String,
    promptCount: Number
  }

  connect() {
    console.log("Tag controller connected", this.element)
    console.log("Available data attributes:", this.element.dataset)
  }

  confirmDelete(event) {
    console.log("confirmDelete called", event)
    console.log("Event target:", event.target)
    console.log("Current target:", event.currentTarget)
    console.log("Element:", this.element)

    // イベントの伝播を停止
    event.stopPropagation()
    // デフォルトの動作を防止
    event.preventDefault()

    // データ属性から情報を取得
    const tagName = event.currentTarget.dataset.tagName || "このタグ"
    const promptCount = event.currentTarget.dataset.tagPromptCount || "0"
    const deleteUrl = event.currentTarget.getAttribute("href")

    console.log(`タグ名: ${tagName}, プロンプト数: ${promptCount}, URL: ${deleteUrl}`)

    if (confirm(`「${tagName}」タグを削除しますか？\n関連するプロンプト: ${promptCount}件`)) {
      console.log("削除を実行します")

      // CSRFトークンを取得
      const token = document.querySelector('meta[name="csrf-token"]').content

      // フェッチAPIを使用して削除リクエストを送信
      fetch(deleteUrl, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': token,
          'Accept': 'text/html, application/json',
          'Content-Type': 'application/json'
        },
        credentials: 'same-origin'
      })
        .then(response => {
          console.log("Response:", response)
          if (response.redirected) {
            window.location.href = response.url
          } else if (response.ok) {
            window.location.reload()
          } else {
            console.error("Error response:", response)
          }
        })
        .catch(error => {
          console.error('Error:', error)
        })
    } else {
      console.log("削除をキャンセルしました")
    }
  }
}

