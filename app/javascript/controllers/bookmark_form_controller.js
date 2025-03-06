import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "url", "submit", "errorMessages"]

  connect() {
    console.log("Bookmark form controller connected")
    this.element.addEventListener("turbo:submit-end", this.handleSubmitEnd.bind(this))
    
    // URLが既に存在するかチェックする
    if (this.hasUrlTarget) {
      this.urlTarget.addEventListener("input", this.debouncedCheckUrlExists.bind(this))
    }
  }
  
  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.handleSubmitEnd.bind(this))
    
    if (this.hasUrlTarget) {
      this.urlTarget.removeEventListener("input", this.debouncedCheckUrlExists.bind(this))
    }
    
    if (this._debounceTimer) {
      clearTimeout(this._debounceTimer)
    }
  }
  
  handleSubmitEnd(event) {
    console.log("Form submission ended", event.detail)
    if (!event.detail.success) {
      // エラー時の処理
      const flashContainer = document.getElementById("flash_messages")
      if (flashContainer) {
        flashContainer.scrollIntoView({ behavior: 'smooth' })
      }
    }
  }
  
  debouncedCheckUrlExists(event) {
    if (this._debounceTimer) {
      clearTimeout(this._debounceTimer)
    }
    
    this._debounceTimer = setTimeout(() => {
      this.checkUrlExists()
    }, 500) // 500ms後に実行
  }
  
  async checkUrlExists() {
    const url = this.urlTarget.value
    if (!url) {
      // URLが空の場合は検証しない
      if (this.hasSubmitTarget) {
        this.submitTarget.disabled = false
      }
      
      if (this.hasErrorMessagesTarget) {
        this.errorMessagesTarget.textContent = ""
        this.errorMessagesTarget.classList.add("hidden")
      }
      return
    }
    
    console.log("Checking if URL exists:", url)
    
    try {
      // CSRFトークンの取得
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
      
      // URLエンコード
      const encodedUrl = encodeURIComponent(url)
      const checkUrl = `/bookmarks/check_exists?url=${encodedUrl}`
      
      console.log("Sending request to:", checkUrl)
      
      const response = await fetch(checkUrl, {
        method: 'GET',
        headers: {
          "Accept": "application/json",
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRF-Token": csrfToken || ''
        },
        credentials: 'same-origin'
      })
      
      if (!response.ok) {
        console.error("HTTP error:", response.status, response.statusText)
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const data = await response.json()
      console.log("Response data:", data)
      
      if (data.exists) {
        // URLが既に存在する場合
        console.log("URL already exists")
        if (this.hasSubmitTarget) {
          this.submitTarget.disabled = true
        }
        
        if (this.hasErrorMessagesTarget) {
          this.errorMessagesTarget.textContent = "このURLは既に登録されています"
          this.errorMessagesTarget.classList.remove("hidden")
        }
      } else {
        // URLが存在しない場合
        console.log("URL does not exist")
        if (this.hasSubmitTarget) {
          this.submitTarget.disabled = false
        }
        
        if (this.hasErrorMessagesTarget) {
          this.errorMessagesTarget.textContent = ""
          this.errorMessagesTarget.classList.add("hidden")
        }
      }
    } catch (error) {
      console.error("Error checking URL existence:", error)
      // エラー時は送信ボタンを有効にしておく
      if (this.hasSubmitTarget) {
        this.submitTarget.disabled = false
      }
    }
  }
} 