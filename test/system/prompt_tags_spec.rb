# spec/system/prompt_tags_spec.rb
require 'rails_helper'

RSpec.describe "プロンプトのタグ機能", type: :system do
  let(:user) { create(:user) }
  let!(:prompt) { create(:prompt, 
    user: user, 
    title: 'RSpec入門ガイド',
    url: 'https://example.com/rspec-guide',
    description: 'Rubyのテストフレームワーク、RSpecの使い方を解説しています。'
  )}
  
  before do
    # ログイン
    sign_in user
    
    # TagSuggestionServiceをモック化
    allow(TagSuggestionService).to receive(:suggest_tags).and_return('Ruby, RSpec, テスト, BDD, TDD')
    
    # タグ提案履歴を作成
    TagSuggestionHistory.create!(
      prompt: prompt,
      user: user,
      suggested_tags: 'Ruby, RSpec, テスト',
      suggested_at: 1.day.ago
    )
    
    TagSuggestionHistory.create!(
      prompt: prompt,
      user: user,
      suggested_tags: 'Ruby, テスト, 自動化',
      suggested_at: 2.hours.ago
    )
  end
  
  it 'プロンプト詳細ページでAIタグ提案が表示されること' do
    visit prompt_path(prompt)
    
    # AIタグ提案セクションが存在する
    expect(page).to have_content('AIタグ提案')
    
    # タグ候補が表示されている
    expect(page).to have_content('Ruby, RSpec, テスト, BDD, TDD')
    
    # タグ選択フォームが存在する
    expect(page).to have_field('tags')
    expect(page).to have_button('タグを適用')
  end
  
  it '過去のタグ提案履歴が表示されること' do
    visit prompt_path(prompt)
    
    # 過去の提案履歴セクションが存在する
    expect(page).to have_content('過去の提案履歴')
    
    # 履歴が表示されている
    expect(page).to have_content('Ruby, RSpec, テスト')
    expect(page).to have_content('Ruby, テスト, 自動化')
  end
  
  it 'タグを適用するとプロンプトにタグが追加されること', js: true do
    visit prompt_path(prompt)
    
    # タグを入力して適用
    fill_in 'tags', with: 'Ruby, テスト, チュートリアル'
    click_button 'タグを適用'
    
    # 成功メッセージが表示される
    expect(page).to have_content('タグを更新しました')
    
    # 適用されたタグが表示される
    expect(page).to have_css('.badge', text: 'ruby')
    expect(page).to have_css('.badge', text: 'テスト')
    expect(page).to have_css('.badge', text: 'チュートリアル')
  end
  
  it 'タグ提案を評価できること', js: true do
    visit prompt_path(prompt)
    
    # 「役立った」評価をクリック
    find('a[title="役立った"]').click
    
    # 成功メッセージが表示される
    expect(page).to have_content('評価を更新しました')
    
    # アイコンが塗りつぶされる
    expect(page).to have_css('.bi-hand-thumbs-up-fill.text-success')
  end
end