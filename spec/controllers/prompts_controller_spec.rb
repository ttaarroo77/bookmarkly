require 'rails_helper'

RSpec.describe Prompt, type: :model do
  let(:user) { create(:user) }
  
  describe 'validations' do
    it { should validate_presence_of(:url) }
    it { should validate_presence_of(:title) }
    
    it 'validates URL format' do
      # 有効なURL
      prompt = build(:prompt, user: user, url: 'https://example.com')
      expect(prompt).to be_valid
      
      # 無効なURL
      prompt = build(:prompt, user: user, url: 'invalid-url')
      expect(prompt).not_to be_valid
    end
  end
  
  describe 'associations' do
    it { should belong_to(:user) }
  end
  
  describe 'tags handling' do
    it 'converts tags_text to tags array' do
      prompt = create(:prompt, user: user, tags_text: 'tag1, tag2, tag3')
      expect(prompt.tags).to eq(['tag1', 'tag2', 'tag3'])
    end
    
    it 'removes duplicate tags' do
      prompt = create(:prompt, user: user, tags_text: 'tag1, tag1, tag2')
      expect(prompt.tags).to eq(['tag1', 'tag2'])
    end
    
    it 'removes empty tags' do
      prompt = create(:prompt, user: user, tags_text: 'tag1, , tag2')
      expect(prompt.tags).to eq(['tag1', 'tag2'])
    end
  end
  
  describe 'scopes' do
    before do
      @prompt1 = create(:prompt, user: user, tags: ['ruby', 'rails'], title: 'Ruby on Rails')
      @prompt2 = create(:prompt, user: user, tags: ['javascript', 'react'], title: 'React')
      @prompt3 = create(:prompt, user: user, tags: ['ruby', 'javascript'], title: 'JavaScript in Ruby')
    end
    
    describe '.with_tag' do
      it 'returns prompts with specific tag' do
        expect(Prompt.with_tag('ruby')).to include(@prompt1, @prompt3)
        expect(Prompt.with_tag('ruby')).not_to include(@prompt2)
      end
    end
    
    describe '.search' do
      it 'returns prompts matching title' do
        expect(Prompt.search('Rails')).to include(@prompt1)
        expect(Prompt.search('Rails')).not_to include(@prompt2, @prompt3)
      end
    end
  end
end