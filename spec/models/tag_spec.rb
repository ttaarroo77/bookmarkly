# spec/models/tag_spec.rb に以下のようなテストを追加
require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:user) { create(:user) }

  describe '.cleanup_unused_tags' do
    it '未使用のタグを削除すること' do
      # 使用中のタグを作成して保存
      used_tag = create(:tag, user: user)
      prompt = create(:prompt, user: user)
      used_tag.save!  # 明示的に保存
      prompt.tags << used_tag

      # 未使用のタグを作成して保存
      unused_tag = create(:tag, user: user)
      unused_tag.save!  # 明示的に保存

      expect {
        Tag.cleanup_unused_tags
      }.to change(Tag, :count).by(-1)

      expect(Tag.exists?(unused_tag.id)).to be false
      expect(Tag.exists?(used_tag.id)).to be true
    end

    it '複数の未使用タグを一括で削除すること' do
      # 使用中のタグを作成
      used_tag = create(:tag, user: user)
      prompt = create(:prompt, user: user)
      prompt.tags << used_tag

      # 複数の未使用タグを作成
      unused_tags = create_list(:tag, 3, user: user)

      expect {
        Tag.cleanup_unused_tags
      }.to change(Tag, :count).by(-3)

      unused_tags.each do |tag|
        expect(Tag.exists?(tag.id)).to be false
      end
      expect(Tag.exists?(used_tag.id)).to be true
    end
  end

  describe '#check_for_cleanup' do
    it 'タグからすべてのプロンプトが削除された時にタグも削除されること' do
      tag = create(:tag, user: user)
      prompt = create(:prompt, user: user)
      prompt.tags << tag

      expect {
        prompt.tags.delete(tag)
      }.to change(Tag, :count).by(-1)

      expect(Tag.exists?(tag.id)).to be false
    end
  end
end