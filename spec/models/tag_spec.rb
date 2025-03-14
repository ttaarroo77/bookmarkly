require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'バリデーション' do
    it 'nameとuser_idがあれば有効であること' do
      tag = build(:tag)
      expect(tag).to be_valid
    end

    it 'nameがなければ無効であること' do
      tag = build(:tag, name: nil)
      expect(tag).not_to be_valid
    end

    it 'user_idがなければ無効であること' do
      tag = build(:tag, user_id: nil)
      expect(tag).not_to be_valid
    end

    it '同一ユーザー内でnameは一意であること' do
      user = create(:user)
      create(:tag, name: 'test', user: user)
      tag = build(:tag, name: 'test', user: user)
      expect(tag).not_to be_valid
    end

    it '異なるユーザー間では同じnameを使用できること' do
      create(:tag, name: 'test', user: create(:user))
      tag = build(:tag, name: 'test', user: create(:user))
      expect(tag).to be_valid
    end
  end

  describe 'アソシエーション' do
    it 'ユーザーに属すること' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    it 'プロンプトと多対多の関係であること' do
      association = described_class.reflect_on_association(:prompts)
      expect(association.macro).to eq :has_and_belongs_to_many
    end
  end
  
  describe '名前の小文字化' do
    let(:user) { create(:user) }
    
    it '保存時に名前が小文字に変換される' do
      tag = create(:tag, name: 'TestTag', user: user)
      expect(tag.name).to eq('testtag')
    end
  end
  
  describe '関連付け' do
    let(:user) { create(:user) }
    
    it 'ユーザーに属する' do
      tag = create(:tag, user: user)
      expect(tag.user).to eq(user)
    end
    
    it 'ユーザーを削除するとタグも削除される' do
      tag = create(:tag, user: user)
      
      expect {
        user.destroy
      }.to change(Tag, :count).by(-1)
    end
  end
  
  describe '.cleanup_unused_tags' do
    let(:user) { create(:user) }
    
    it '使用されていないタグを削除する' do
      # タグを作成
      used_tag = create(:tag, user: user)
      unused_tag = create(:tag, user: user)
      
      # 使用されているタグとプロンプトを関連付け
      prompt = create(:prompt, user: user)
      prompt.tags << used_tag
      
      expect {
        Tag.cleanup_unused_tags
      }.to change(Tag, :count).by(-1)
      
      expect(Tag.exists?(unused_tag.id)).to be_falsey
      expect(Tag.exists?(used_tag.id)).to be_truthy
    end
  end
end