# PostgreSQL配列型検索の対策実施報告

## 実施した対策

### 1. コントローラーの修正

- [x] タグフィルタリング部分の修正
  ```ruby
  @bookmarks = @bookmarks.where("tags @> ARRAY[?]::text[]", params[:tag])
  ```
- [x] 検索クエリ部分の修正
  ```ruby
  @bookmarks = @bookmarks.where("title ILIKE ? OR url ILIKE ? OR tags @> ARRAY[?]::text[]", query, query, params[:query])
  ```
- [x] タグソート部分の修正
  ```ruby
  @tags = @tags.sort_by do |tag|
    [-current_user.bookmarks.where("tags @> ARRAY[?]::text[]", tag).maximum(:created_at).to_i, tag]
  end
  ```

### 2. モデルの修正

- [x] `with_tag`スコープの修正
  ```ruby
  scope :with_tag, ->(tag) { where("tags @> ARRAY[?]::text[]", tag) if tag.present? }
  ```

### 3. 例外処理の追加

- [x] 存在しないブックマークへのアクセス時の例外処理
  ```ruby
  def set_bookmark
    begin
      @bookmark = current_user.bookmarks.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "指定されたブックマークが見つかりませんでした。"
      redirect_to bookmarks_path
    end
  end
  ```

## テスト結果

- [x] タグによるフィルタリングが正常に動作することを確認
- [x] 検索クエリとタグ検索の組み合わせが正常に動作することを確認
- [x] タグのソートが正常に動作することを確認
- [x] 存在しないブックマークへのアクセス時に適切なエラーメッセージが表示されることを確認
- [ ] 特殊文字を含むタグでも正常に検索できるか確認（今後のテスト項目）

## 解決策の説明

1. **問題の原因**:
   - ActiveRecordのプレースホルダー`?`が`= ANY`演算子の左側に配置されると、PostgreSQLはこれを文字列リテラルとして解釈し、配列型との比較ができなくなる。
   - エラーメッセージ「`op ANY/ALL (array) requires array on right side`」は、`ANY`演算子の左側に配列型が必要なことを示している。

2. **解決策**:
   - `@>`演算子（配列包含）を使用して、「配列が特定の要素を含むか」を検索する方法に変更。
   - `ARRAY[?]::text[]`構文で、パラメータを明示的に配列型にキャストすることで型の不一致を防止。
   - ActiveRecordのプレースホルダーを正しく使用して、SQLインジェクションを防止。

3. **メリット**:
   - 構文エラーが解消され、タグ検索が正常に機能するようになった。
   - 型の明示的なキャストにより、データベースエンジンが適切な実行計画を選択できるようになった。
   - セキュリティリスクを最小限に抑えながら、柔軟な検索が可能になった。

## 今後の課題

- [ ] 配列型検索のパフォーマンス最適化
- [ ] インデックスの効果的な活用方法の検討
- [ ] 複数タグによる検索機能の実装
- [ ] タグ検索のテストケースの追加
- [ ] 特殊文字を含むタグの検索機能の検証

## 学んだ教訓

1. PostgreSQLの配列型を使用する際は、適切な比較演算子を選択することが重要。
2. ActiveRecordのプレースホルダーと配列演算子を組み合わせる際は、生成されるSQLを確認する必要がある。
3. 型キャストを明示的に行うことで、データベースエンジンが適切な実行計画を選択できるようになる。
4. 例外処理を適切に実装することで、ユーザー体験を向上させることができる。 