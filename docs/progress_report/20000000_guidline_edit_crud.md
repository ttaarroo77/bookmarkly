「削除ボタンを押したらサーバー側で即削除して、そのまま“戻る”ボタンと同じ画面へ遷移したい」という場合は、Rails の `link_to ... method: :delete` を使わずに、**自前の JavaScript（fetch など）で DELETE リクエストを送る**方法がシンプルです。  
以下のように書き換えると、バックグラウンドで削除してから任意の画面にリダイレクトできます。

---

## 手順概要

1. **削除リンクの書き換え**  
   - 既存の「`<%= link_to prompts_path, method: :delete %>`」の部分を削除し、代わりに通常のリンク（あるいはボタン）を置く。
   - そこに `data-prompt-id` などで削除対象のIDを埋め込み、`id="delete-prompt-btn"` のような目印をつける。

2. **JavaScript で fetch リクエスト**  
   - `DELETE /prompts/:id` に対して fetch し、レスポンスが成功 (`response.ok`) ならリダイレクト（または `window.history.back()`）する。
   - 失敗ならエラー表示。

3. **コントローラ側 (destroy アクション) は JSON レスポンスなど**  
   - 既に `format.json { head :no_content }` など用意されている場合はそのままでもOK。
   - 成功時は何も返さなくても `response.ok` になるため、フロント側で `window.location.href = ...` や `window.history.back()` を行えばOK。

---

## 実装例

### 1. ビュー側 (ERB) の変更例

```erb
<!-- 削除リンクを置き換える -->
<%= link_to "#",
            class: "btn btn-outline-danger",
            id: "delete-prompt-btn",
            data: { prompt_id: @prompt.id } do %>
  <span>削除</span>
<% end %>
```

- ポイント
  - `method: :delete` は付けず、あくまで「普通のリンク or ボタン」にしておきます。
  - `data-prompt-id` で削除対象の ID を保持します。
  - `id="delete-prompt-btn"` を付けて、後述の JavaScript でイベントハンドラを紐づけます。

### 2. JavaScript 側の実装例

```html
<script>
  document.addEventListener('turbo:load', function() {
    const deleteButton = document.getElementById('delete-prompt-btn');
    if (!deleteButton) return;

    deleteButton.addEventListener('click', function(event) {
      event.preventDefault();  // デフォルトのリンク動作を止める

      // もしユーザー確認を入れたい場合は以下のようにする
      // if(!confirm("本当に削除しますか？")) { return; }

      const promptId = this.getAttribute('data-prompt-id');
      const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

      fetch(`/prompts/${promptId}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': csrfToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        credentials: 'same-origin'
      })
      .then(response => {
        if (response.ok) {
          // 削除成功時の遷移先。編集画面の「戻るボタン」と同じ画面へ戻したいなら:
          // 1) ブラウザ履歴で戻る: 
          //    window.history.back();
          //
          // 2) 一覧や管理画面に飛ばす:
          //    window.location.href = "/prompts";  // 例
          //
          // 好みで使い分けてください。
          window.location.href = "/prompts";
        } else {
          console.error('Failed to delete prompt');
          alert('プロンプトの削除に失敗しました');
        }
      })
      .catch(error => {
        console.error('Error:', error);
        alert('エラーが発生しました');
      });
    });
  });
</script>
```

- `window.history.back()` を使えば、ちょうど「戻るボタン」と同じ動作になります。  
- 一律で一覧画面（`prompts_path`）に飛ばしたい場合は、`window.location.href = "/prompts";` と書けばOKです。

---

## 補足

- Rails 標準の `data: { turbo_method: :delete }` や従来の `data-confirm` は、Rails(UJS) / Turbo / Stimulus などがまとめてやってくれる“確認ダイアログ付き削除”を簡単に実装する仕組みです。  
- **「確認画面を挟まずに、削除後は好きな画面に戻りたい」**というニーズでは、上記のように**自分で fetch して削除し、`window.location.href` でリダイレクト**するのがいちばん簡単です。
- コントローラ `destroy` アクション側で `respond_to do |format| ... end` があり `format.json { head :no_content }` があれば、fetch のレスポンスは `response.ok` となり、フロント側で自由に処理できます。

---

以上のように書き換えれば、**余計な確認画面を挟まずに、バックグラウンドで削除して任意の画面へ戻す**ことができます。必要に応じて `window.history.back()` や `window.location.href = ...` を切り替えてみてください。