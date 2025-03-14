# 20250226101856_add_name_to_users.rb - ユーザー名追加


class AddNameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string
  end
end
