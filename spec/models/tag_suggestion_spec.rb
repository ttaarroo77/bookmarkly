require 'rails_helper'

RSpec.describe TagSuggestion, type: :model do
  describe 'バリデーション' do
    it 'nameがあれば有効であること' do
      tag_suggestion = TagSuggestion.new(name: 'suggestion')
      expect(tag_suggestion).to be_valid
    end

    it 'nameがなければ無効であること' do
      tag_suggestion = TagSuggestion.new(name: nil)
      expect(tag_suggestion).not_to be_valid
    end

    it 'nameは一意であること' do
      TagSuggestion.create(name: 'suggestion')
      tag_suggestion = TagSuggestion.new(name: 'suggestion')
      expect(tag_suggestion).not_to be_valid
    end
  end

  describe '.popular_tags' do
    before do
      TagSuggestion.create(name: 'popular', count: 10)
      TagSuggestion.create(name: 'less_popular', count: 5)
      TagSuggestion.create(name: 'unpopular', count: 1)
    end

    it '人気順にタグを返すこと' do
      popular_tags = TagSuggestion.popular_tags(2)
      expect(popular_tags.map(&:name)).to eq(['popular', 'less_popular'])
    end

    it '指定した数のタグを返すこと' do
      popular_tags = TagSuggestion.popular_tags(1)
      expect(popular_tags.length).to eq(1)
    end
  end
end 