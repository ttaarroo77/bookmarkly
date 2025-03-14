require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it 'emailとpasswordがあれば有効であること' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'emailがなければ無効であること' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it 'passwordがなければ無効であること' do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
    end

    it 'emailは一意であること' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
    end
  end

  describe 'アソシエーション' do
    it 'プロンプトを複数持つこと' do
      association = described_class.reflect_on_association(:prompts)
      expect(association.macro).to eq :has_many
    end

    it 'タグを複数持つこと' do
      association = described_class.reflect_on_association(:tags)
      expect(association.macro).to eq :has_many
    end
  end

  describe 'ユーザー削除時の関連データ' do
    let(:user) { create(:user) }
    
    it 'ユーザーを削除すると関連するプロンプトも削除されること' do
      create(:prompt, user: user)
      expect { user.destroy }.to change(Prompt, :count).by(-1)
    end

    it 'ユーザーを削除すると関連するタグも削除されること' do
      create(:tag, user: user)
      expect { user.destroy }.to change(Tag, :count).by(-1)
    end
  end
end 