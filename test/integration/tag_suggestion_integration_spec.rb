# spec/integration/tag_suggestion_integration_spec.rb
require 'rails_helper'

RSpec.describe "タグ提案の統合テスト", type: :request do
  let(:user) { create(:user) }
  let!(:prompt) { create(:prompt, 
    user: user, 
    title: 'GraphQLとRailsの連携方法',
    url: 'https://example.com/graphql-rails',
    description: 'RailsアプリケーションでGraphQLを使って効率的なAPIを構築する方法'
  )}
  
  before do
    sign_in user
  end
  
  it 'プロンプト詳細表示時にタグ提案サービスが呼ばれること' do
    expect(TagSuggestionService).to receive(:suggest_tags).with(prompt).and_return('Rails, GraphQL, API, Ruby, バックエンド')
    expect(TagSuggestionHistory).to receive(:record).with(prompt, 'Rails, GraphQL, API, Ruby, バックエンド', user)
    
    get prompt_path(prompt)
    
    expect(response).to have_http_status(:success)
    expect(response.body).to include('Rails, GraphQL, API, Ruby, バックエンド')
  end
  
  it 'タグを適用するとプロンプトのタグが更新されること' do
    # 事前にタグが存在しないことを確認
    expect(prompt.tags.count).to eq(0)
    
    # タグを適用
    post apply_tags_prompt_path(prompt), params: { tags: 'Rails, GraphQL, API' }
    
    # リダイレクトされることを確認
    expect(response).to redirect_to(prompt_path(prompt))
    
    # タグが追加されたことを確認
    prompt.reload
    expect(prompt.tags.count).to eq(3)
    expect(prompt.tags.pluck(:name)).to contain_exactly('rails', 'graphql', 'api')
  end
  
  it 'タグ提案を評価できること' do
    # 履歴を作成
    history = TagSuggestionHistory.create!(
      prompt: prompt,
      user: user,
      suggested_tags: 'Rails, GraphQL, API',
      suggested_at: Time.current
    )
    
    # 評価を送信
    post rate_tag_suggestion_prompt_path(prompt), params: { history_id: history.id, rating: 1 }
    
    # リダイレクトされることを確認
    expect(response).to redirect_to(prompt_path(prompt))
    
    # 評価が更新されたことを確認
    history.reload
    expect(history.rating).to eq(1)
  end
end