// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// Bootstrap is loaded from CDN in application.html.erb

document.addEventListener("DOMContentLoaded", function() {
  console.log("DOM fully loaded - No modules");
  
  // aria-hidden属性を削除
  document.querySelectorAll('[aria-hidden="true"]').forEach(el => {
    el.removeAttribute('aria-hidden');
    console.log("Removed aria-hidden from", el);
  });
  
  // クリックイベントのデバッグ
  document.addEventListener("click", function(e) {
    console.log("Click event on:", e.target);
  });
});
