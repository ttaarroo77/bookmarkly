class Tag < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :prompts

  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }
  
  before_validation :normalize_name
  
  def normalize_name
    self.name = name.downcase.strip if name.present?
  end
  
  def usage_count
    prompts.count
  end
  
  scope :search, ->(query) {
    where("name ILIKE ?", "%#{query}%") if query.present?
  }
  
  scope :sorted_by, ->(sort_type) {
    case sort_type
    when 'count_desc'
      joins(:prompts)
        .group('tags.id')
        .order('COUNT(prompts.id) DESC')
    when 'count_asc'
      joins(:prompts)
        .group('tags.id')
        .order('COUNT(prompts.id) ASC')
    else
      order(name: :asc)
    end
  }
end 