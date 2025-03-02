import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "tags"]

  connect() {
    this.inputTarget.addEventListener("keydown", this.handleKeyDown.bind(this))
  }

  disconnect() {
    this.inputTarget.removeEventListener("keydown", this.handleKeyDown.bind(this))
  }

  handleKeyDown(event) {
    // カンマやEnterキーで入力を確定
    if (event.key === "," || event.key === "Enter") {
      event.preventDefault()
      this.addTag()
    }
  }

  addTag() {
    const value = this.inputTarget.value.trim()

    if (value) {
      // 既存のタグとして追加
      let tags = []

      // 現在のタグテキストを取得
      if (this.tagsTarget.value) {
        tags = this.tagsTarget.value.split(",").map(tag => tag.trim()).filter(Boolean)
      }

      // 新しいタグを追加（重複排除）
      if (!tags.includes(value)) {
        tags.push(value)
        this.tagsTarget.value = tags.join(", ")
      }

      // 入力フィールドをクリア
      this.inputTarget.value = ""
    }
  }

  // タグをクリックして削除
  removeTag(event) {
    const tagToRemove = event.currentTarget.dataset.tag
    let tags = this.tagsTarget.value.split(",").map(tag => tag.trim())

    // タグを削除
    tags = tags.filter(tag => tag !== tagToRemove)
    this.tagsTarget.value = tags.join(", ")

    // タグ表示を更新
    event.currentTarget.remove()
  }
}