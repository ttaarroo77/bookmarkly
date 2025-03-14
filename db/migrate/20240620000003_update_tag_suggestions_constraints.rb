# 20240620000003_update_tag_suggestions_constraints.rb - タグ候補制約更新


class UpdateTagSuggestionsConstraints < ActiveRecord::Migration[6.1]
  def change
    # confidenceカラムにデフォルト値を設定
    change_column_default :tag_suggestions, :confidence, from: nil, to: 0.0

    # prompt_idとnameの組み合わせでユニーク制約を追加（存在しない場合のみ）
    unless index_exists?(:tag_suggestions, [:prompt_id, :name], unique: true)
      add_index :tag_suggestions, [:prompt_id, :name], unique: true
    end
  end
end