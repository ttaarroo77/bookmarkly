class CleanupTagsData < ActiveRecord::Migration[8.0]
  def up
    # タグデータのクリーンアップ
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
