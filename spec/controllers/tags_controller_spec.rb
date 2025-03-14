require 'rails_helper'

RSpec.describe TagsController, type: :controller do
  let(:user) { create(:user) }
  
  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'ステータスコード200を返すこと' do
      get :index
      expect(response).to have_http_status(200)
    end

    it 'ユーザーのタグを取得すること' do
      tag1 = create(:tag, user: user)
      tag2 = create(:tag, user: user)
      other_user_tag = create(:tag, user: create(:user))
      
      get :index
      
      # assignsの代わりにcontroller.instance_variable_getを使用
      tags = controller.instance_variable_get(:@tags)
      expect(tags).to include(tag1, tag2)
      expect(tags).not_to include(other_user_tag)
    end
  end

  describe 'GET #show' do
    let(:tag) { create(:tag, user: user) }
    
    it 'ステータスコード200を返すこと' do
      get :show, params: { id: tag.id }
      expect(response).to have_http_status(200)
    end
    
    it '指定したタグを取得すること' do
      get :show, params: { id: tag.id }
      
      # assignsの代わりにcontroller.instance_variable_getを使用
      expect(controller.instance_variable_get(:@tag)).to eq(tag)
    end
  end

  describe 'POST #create' do
    context '有効なパラメータの場合' do
      it 'タグを作成すること' do
        expect {
          post :create, params: { tag: { name: 'newtag' } }
        }.to change(Tag, :count).by(1)
      end
      
      it 'タグ一覧にリダイレクトすること' do
        post :create, params: { tag: { name: 'newtag' } }
        expect(response).to redirect_to(tags_path)
      end
    end
    
    context '無効なパラメータの場合' do
      it 'タグを作成しないこと' do
        expect {
          post :create, params: { tag: { name: '' } }
        }.not_to change(Tag, :count)
      end
      
      it 'newテンプレートを再表示すること' do
        post :create, params: { tag: { name: '' } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:tag) { create(:tag, user: user) }
    
    it 'タグを削除すること' do
      expect {
        delete :destroy, params: { id: tag.id }
      }.to change(Tag, :count).by(-1)
    end
    
    it 'タグ一覧にリダイレクトすること' do
      delete :destroy, params: { id: tag.id }
      expect(response).to redirect_to(tags_path)
    end
  end
end 