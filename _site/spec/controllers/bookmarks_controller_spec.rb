require 'rails_helper'

RSpec.describe Bookmark, type: :model do
  let(:user) { create(:user) }
  
  describe 'validations' do
    it { should validate_presence_of(:url) }
    it { should validate_presence_of(:title) }
    
    it 'validates URL format' do
      # 有効なURL
      bookmark = build(:bookmark, user: user, url: 'https://example.com')
      expect(bookmark).to be_valid
      
      # 無効なURL
      bookmark = build(:bookmark, user: user, url: 'invalid-url')
      expect(bookmark).not_to be_valid
    end
  end
  
  describe 'associations' do
    it { should belong_to(:user) }
  end
  
  describe 'tags handling' do
    it 'converts tags_text to tags array' do
      bookmark = create(:bookmark, user: user, tags_text: 'tag1, tag2, tag3')
      expect(bookmark.tags).to eq(['tag1', 'tag2', 'tag3'])
    end
    
    it 'removes duplicate tags' do
      bookmark = create(:bookmark, user: user, tags_text: 'tag1, tag1, tag2')
      expect(bookmark.tags).to eq(['tag1', 'tag2'])
    end
    
    it 'removes empty tags' do
      bookmark = create(:bookmark, user: user, tags_text: 'tag1, , tag2')
      expect(bookmark.tags).to eq(['tag1', 'tag2'])
    end
  end
  
  describe 'scopes' do
    before do
      @bookmark1 = create(:bookmark, user: user, tags: ['ruby', 'rails'], title: 'Ruby on Rails')
      @bookmark2 = create(:bookmark, user: user, tags: ['javascript', 'react'], title: 'React')
      @bookmark3 = create(:bookmark, user: user, tags: ['ruby', 'javascript'], title: 'JavaScript in Ruby')
    end
    
    describe '.with_tag' do
      it 'returns bookmarks with specific tag' do
        expect(Bookmark.with_tag('ruby')).to include(@bookmark1, @bookmark3)
        expect(Bookmark.with_tag('ruby')).not_to include(@bookmark2)
      end
    end
    
    describe '.search' do
      it 'returns bookmarks matching title' do
        expect(Bookmark.search('Rails')).to include(@bookmark1)
        expect(Bookmark.search('Rails')).not_to include(@bookmark2, @bookmark3)
      end
    end
  end
end