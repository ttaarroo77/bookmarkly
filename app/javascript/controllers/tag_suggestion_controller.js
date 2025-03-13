import { Controller } from "@hotwired/stimulus"

// タグ候補管理用のStimulusコントローラー
export default class extends Controller {
  static targets = ["input", "suggestion"]

  connect() {
    console.log("Tag suggestion controller connected")
  }

  // タグ候補がクリックされたときの処理
  addTag(event) {
    const tagElement = event.currentTarget
    const tagName = tagElement.dataset.tag

    if (!tagName) return

    // 現在のタグリストを取得
    const inputField = this.inputTarget
    const currentTags = inputField.value.split(',').map(tag => tag.trim()).filter(tag => tag !== '')

    // 既に同じタグが存在しないか確認
    if (!currentTags.includes(tagName)) {
      // タグを追加
      if (currentTags.length > 0) {
        inputField.value = currentTags.join(', ') + ', ' + tagName
      } else {
        inputField.value = tagName
      }

      // 追加後のスタイル変更
      tagElement.classList.remove('bg-light', 'text-dark')
      tagElement.classList.add('bg-success', 'text-white')

      // アイコンを変更
      const icon = tagElement.querySelector('i')
      if (icon) {
        icon.classList.remove('bi-plus-circle-fill')
        icon.classList.add('bi-check-circle-fill')
      }

      // フォーカスを入力欄に戻す
      inputField.focus()
    }
  }
} 