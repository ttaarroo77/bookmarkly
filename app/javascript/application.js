// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// Bootstrap is loaded from CDN in application.html.erb
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("DOMContentLoaded", function () {
  console.log("DOM fully loaded - No modules");

  // aria-hidden属性を削除
  document.querySelectorAll('[aria-hidden="true"]').forEach(el => {
    el.removeAttribute('aria-hidden');
    console.log("Removed aria-hidden from", el);
  });

  // クリックイベントのデバッグ
  document.addEventListener("click", function (e) {
    console.log("Click event on:", e.target);
  });

  // 削除フォームのサブミットイベントを処理
  document.querySelectorAll('form[action*="/prompts/"][method="post"]').forEach(form => {
    if (form.querySelector('input[name="_method"][value="delete"]')) {
      form.addEventListener('submit', function (e) {
        console.log("Delete form submitted");
      });
    }
  });
});

// Turboのフォーム送信後のリダイレクトを確実にするための設定
document.addEventListener("turbo:submit-end", (event) => {
  console.log("Turbo submit end:", event);
  if (event.detail.success) {
    const form = event.target;
    console.log("Form submitted successfully:", form);

    // 削除フォームの場合は、プロンプト一覧ページにリダイレクト
    if (form.querySelector('input[name="_method"][value="delete"]')) {
      console.log("Redirecting to prompts index");
      window.location.href = "/prompts";
    }
    // data-turbo="false"が設定されているフォームの場合は、Turboによる処理をスキップ
    else if (form.dataset.turbo === "false") {
      Turbo.visit(event.detail.fetchResponse.response.url);
    }
  }
});
