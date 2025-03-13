class User < ApplicationRecord
  # Deviseのモジュール
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  # 関連付け
  has_many :prompts, dependent: :destroy
  has_many :tags, dependent: :destroy
  
  # バリデーション
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end