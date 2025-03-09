class Tag < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :prompts

  validates :name, presence: true, uniqueness: { scope: :user_id }
  
  before_save :normalize_name
  
  private
  
  def normalize_name
    self.name = name.strip.downcase if name.present?
  end
end 