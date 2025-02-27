# タグシステムのクリーンアップと修正

## 問題の概要

ブックマークのタグ表示と検索機能に複数の問題が発生していました：

1. タグデータが不正な形式で保存されていた（二重引用符や括弧を含む）
2. タグによる絞り込み検索でエラーが発生していた
3. タグの表示が正しく行われていなかった

## 実施した対策

### 1. データクリーンアップ

- [x] マイグレーションファイルの作成
  ```ruby
  class CleanupTagsData < ActiveRecord::Migration[8.0]
    def up
      execute <<-SQL
        UPDATE bookmarks
        SET tags = ARRAY(
          SELECT TRIM(BOTH '"' FROM regexp_replace(unnest(tags), '\\\\"|\\[|\\]', '', 'g'))
          WHERE tags IS NOT NULL AND tags <> '{}'
        )::text[]
        WHERE tags IS NOT NULL AND tags <> '{}'
      SQL
    end
    
    def down
      # ロールバック処理は不要
    end
  end
  ```

- [x] Rakeタスクの作成
  ```ruby
  namespace :bookmarks do
    desc "タグデータのクリーンアップ"
    task cleanup_tags: :environment do
      Bookmark.find_each do |bookmark|
        if bookmark.tags.present?
          # 現在のタグを取得
          current_tags = bookmark.tags
          
          # タグをクリーンアップ
          cleaned_tags = current_tags.map do |tag|
            if tag.is_a?(String)
              # 引用符や括弧を削除
              tag.gsub(/^\[|\]$/, '').gsub(/^"|"$/, '').gsub(/\\"/, '"').strip
            else
              tag.to_s
            end
          end.reject(&:empty?).uniq
          
          # クリーンアップされたタグが異なる場合のみ更新
          if cleaned_tags != current_tags
            bookmark.update_column(:tags, cleaned_tags)
            puts "Bookmark ID: #{bookmark.id} のタグを更新しました: #{current_tags.inspect} -> #{cleaned_tags.inspect}"
          end
        end
      end
      
      puts "タグのクリーンアップが完了しました。"
    end
  end
  ```

### 2. コントローラーの修正

- [x] タグによるフィルタリング部分の修正
  ```ruby
  # タグによるフィルタリング
  if params[:tag].present?
    # タグの前後の引用符を削除
    clean_tag = params[:tag].gsub(/^"|"$/, '').strip
    
    # 配列型に対して@>演算子を使用
    @bookmarks = @bookmarks.where("tags::text[] @> ARRAY[?]::text[]", clean_tag)
  end
  ```

### 3. モデルの修正

- [x] `with_tag`スコープの修正
  ```ruby
  scope :with_tag, ->(tag) { where("tags::text[] @> ARRAY[?]::text[]", tag) if tag.present? }
  ```

### 4. ビューの修正

- [x] デバッグ情報の完全削除
  ```erb
  <% if bookmark.tags.present? %>
    <div class="mt-1">
      <% bookmark.tags.each do |tag| %>
        <%= link_to tag, bookmarks_path(tag: tag), class: "badge bg-light text-dark text-decoration-none me-1" %>
      <% end %>
    </div>
  <% end %>
  ```

## 結果

- [x] タグが正しい形式で表示されるようになった
- [x] タグによる絞り込み検索が正常に機能するようになった
- [x] タグクラウドが正しく表示されるようになった
- [x] 特殊文字を含むタグも正しく処理されるようになった
- [x] デバッグ情報が完全に削除され、UIがクリーンになった

## 学んだ教訓

1. PostgreSQLの配列型を使用する際は、カラムの型定義が重要
2. 型の不一致がある場合は、明示的なキャストを使用して解決できる
3. データの整合性を保つためには、定期的なクリーンアップが重要
4. エラーメッセージとヒントを注意深く読むことで、問題の解決策を見つけることができる
5. デバッグ情報は開発中に役立つが、本番環境では非表示にすべき
6. コメントアウトではなく、不要なコードは完全に削除することでコードの可読性が向上する

## 今後の課題

- [ ] タグ入力時のバリデーション強化
- [ ] 複数タグによる検索機能の実装
- [ ] タグのオートコンプリート機能の追加
- [ ] タグ関連のテストケースの追加
- [ ] データベースのマイグレーションを最適化して、`tags`カラムが確実に`text[]`型として定義されるようにする