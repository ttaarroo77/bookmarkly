class CreatePrompts < ActiveRecord::Migration[8.0]
  def change
    create_table :prompts do |t|
      t.text :title
      t.text :url
      t.text :description
      t.text :tags
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
