# app/models/user.rb - ユーザーモデル（Devise使用）


class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  # アソシエーション
  has_many :prompts, dependent: :destroy
  has_many :tags, dependent: :destroy
  
  # バリデーション
  validates :email, presence: true, uniqueness: true
  
  # 名前のデフォルト値を設定（メールアドレスの@前の部分）
  before_validation :set_default_name, if: -> { name.blank? && email.present? }
  
  private
  
  def set_default_name
    self.name = email.split('@').first
  end
end