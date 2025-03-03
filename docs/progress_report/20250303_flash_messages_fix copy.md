# フラッシュメッセージ改善レポート (2025-03-03)

## 1. バグ概要
- **バグID**: FLASH-001
- **報告日**: 2025-03-03
- **報告者**: 開発者
- **バグ概要**: ログイン・ログアウト時のフラッシュメッセージが重複して表示される
- **発生条件**: ユーザーがログインまたはログアウトを行った時
- **期待する挙動**: フラッシュメッセージが1回だけ適切に表示される
- **実際の挙動**: 同じメッセージが2回表示される
- **重要度**: 中
- **緊急度**: 中

## 2. 原因分析
1. `application.html.erb`で2つの異なる方法でフラッシュメッセージを表示
   - 直接の`notice`/`alert`表示
   - `shared/_flash.html.erb`パーシャル経由での表示
2. Turbo Streamによる非同期更新との競合の可能性

## 3. 対応内容
### 3.1 実装した修正
- [ ] `application.html.erb`からフラッシュ表示を一元化
- [ ] `_flash.html.erb`のスタイリングを改善
- [ ] Bootstrapのアラートスタイルを適用
- [ ] 閉じるボタンを追加

### 3.2 コード変更
```ruby
# app/views/shared/_flash.html.erb
<div class="container mt-3">
  <% flash.each do |key, message| %>
    <div class="alert alert-<%= key == 'notice' ? 'success' : 'danger' %> alert-dismissible fade show">
      <%= message %>
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
  <% end %>
</div>
```

## 4. 検証結果
- [ ] ログイン時のメッセージ表示を確認
- [ ] ログアウト時のメッセージ表示を確認
- [ ] Turbo Stream経由の更新を確認
- [ ] レスポンシブデザインの確認

## 5. 残課題
- [ ] フラッシュメッセージの自動非表示機能の追加検討
- [ ] メッセージタイプに応じたアイコン表示の追加検討

## 6. Git管理
```bash
# ブランチ作成
git checkout -b fix/flash-messages

# 変更をコミット
git add app/views/layouts/application.html.erb app/views/shared/_flash.html.erb
git commit -m "フラッシュメッセージの表示を改善"

# リモートにプッシュ
git push origin fix/flash-messages
```

## 7. 今後の改善案
1. フラッシュメッセージのアニメーション効果追加
2. メッセージタイプの拡張（warning, infoなど）
3. 国際化対応の改善

## 8. 学んだこと
- Turbo Streamとフラッシュメッセージの連携方法
- Bootstrapアラートコンポーネントの効果的な使用方法
- パーシャルを使用したビューの整理方法 