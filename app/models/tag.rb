class Tag < ApplicationRecord
  has_many :bookmark_tags, dependent: :destroy
  has_many :bookmarks, through: :bookmark_tags
  
  validates :name, presence: true, uniqueness: true
  
  # タグ名を文字列として返すメソッド
  def to_s
    name
  end
end 