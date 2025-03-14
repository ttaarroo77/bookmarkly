# spec/models/prompt_spec.rb - プロンプトモデルのテスト


require 'rails_helper'

RSpec.describe Prompt, type: :model do
  describe 'バリデーション' do
    it 'titleとcontentとuser_idがあれば有効であること' do
      prompt = build(:prompt)
      expect(prompt).to be_valid
    end

    it 'titleがなければ無効であること' do
      prompt = build(:prompt, title: nil)
      expect(prompt).not_to be_valid
    end

    it 'contentがなければ無効であること' do
      prompt = build(:prompt, content: nil)
      expect(prompt).not_to be_valid
    end

    it 'user_idがなければ無効であること' do
      prompt = build(:prompt, user_id: nil)
      expect(prompt).not_to be_valid
    end
  end

  describe 'アソシエーション' do
    it 'ユーザーに属すること' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    it 'タグと多対多の関係であること' do
      association = described_class.reflect_on_association(:tags)
      expect(association.macro).to eq :has_and_belongs_to_many
    end
  end

  describe '#save_tags' do
    let(:user) { create(:user) }
    let(:prompt) { create(:prompt, user: user) }

    it 'タグを保存できること' do
      prompt.save_tags(['tag1', 'tag2'])
      expect(prompt.tags.count).to eq 2
      expect(prompt.tags.pluck(:name)).to contain_exactly('tag1', 'tag2')
    end

    it '空のタグは保存しないこと' do
      prompt.save_tags(['tag1', '', nil])
      expect(prompt.tags.count).to eq 1
      expect(prompt.tags.first.name).to eq 'tag1'
    end

    it '同じタグは重複して保存しないこと' do
      prompt.save_tags(['tag1', 'tag1'])
      expect(prompt.tags.count).to eq 1
    end

    it 'タグ名は小文字で保存されること' do
      prompt.save_tags(['TAG1'])
      expect(prompt.tags.first.name).to eq 'tag1'
    end

    it 'タグにはプロンプトのユーザーIDが設定されること' do
      prompt.save_tags(['newtag'])
      expect(prompt.tags.first.user_id).to eq user.id
    end

    it '既存のタグをクリアして新しいタグを設定すること' do
      prompt.save_tags(['tag1'])
      prompt.save_tags(['tag2'])
      expect(prompt.tags.count).to eq 1
      expect(prompt.tags.first.name).to eq 'tag2'
    end
  end
end