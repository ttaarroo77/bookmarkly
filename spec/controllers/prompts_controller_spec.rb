# spec/controllers/prompts_controller_spec.rb 

require 'rails_helper'

RSpec.describe PromptsController, type: :controller do
  # テスト用のユーザーを作成
  let(:user) { create(:user) }
  
  # 各テスト前にログイン
  before do
    sign_in user
  end

  # 共通の変数設定
  let(:valid_attributes) do
    attributes_for(:prompt).merge(user_id: user.id)
  end
  let(:invalid_attributes) { attributes_for(:prompt, url: nil, title: nil) }

  describe "GET #index" do
    before do
      @prompt1 = create(:prompt, user: user)
      @prompt2 = create(:prompt, user: user)
      get :index
    end

    it "ステータスコード200を返す" do
      expect(response).to have_http_status(200)
    end

    it "indexテンプレートをレンダリングする" do
      expect(response).to render_template(:index)
    end

    it "ユーザーのプロンプトを@promptsに割り当てる" do
      prompts = controller.instance_variable_get(:@prompts)
      expect(prompts).to include(@prompt1, @prompt2)
    end
  end

  describe "GET #show" do
    let(:prompt) { create(:prompt, user: user) }

    before do
      get :show, params: { id: prompt.id }
    end

    it "showテンプレートをレンダリングする" do
      expect(response).to render_template(:show)
    end

    it "リクエストされたプロンプトを@promptに割り当てる" do
      expect(controller.instance_variable_get(:@prompt)).to eq(prompt)
    end
  end

  describe "GET #new" do
    before do
      get :new
    end

    it "ステータスコード200を返す" do
      expect(response).to have_http_status(200)
    end

    it "newテンプレートをレンダリングする" do
      expect(response).to render_template(:new)
    end

    it "新しいプロンプトを@promptに割り当てる" do
      expect(controller.instance_variable_get(:@prompt)).to be_a_new(Prompt)
    end
  end

  describe "POST #create" do
    context "有効なパラメータの場合" do
      it "新しいプロンプトを作成する" do
        expect {
          post :create, params: { prompt: valid_attributes }
        }.to change(Prompt, :count).by(1)
      end

      it "プロンプト詳細ページにリダイレクトする" do
        post :create, params: { prompt: valid_attributes }
        expect(response).to redirect_to(Prompt.last)
      end

      it "フラッシュメッセージを表示する" do
        post :create, params: { prompt: valid_attributes }
        expect(flash[:notice]).to be_present
      end

      it "タグを正しく処理する" do
        post :create, params: { 
          prompt: valid_attributes.merge(tags_text: "tag1, tag2, tag3") 
        }
        prompt = Prompt.last
        expect(prompt.tags.count).to eq(3)
        expect(prompt.tags.map(&:name)).to include("tag1", "tag2", "tag3")
      end

      it "重複するタグを一度だけ保存する" do
        post :create, params: { 
          prompt: valid_attributes.merge(tags_text: "tag1, tag1, tag1") 
        }
        prompt = Prompt.last
        expect(prompt.tags.count).to eq(1)
        expect(prompt.tags.first.name).to eq("tag1")
      end
    end

    context "無効なパラメータの場合" do
      it "新しいプロンプトを作成しない" do
        expect {
          post :create, params: { prompt: invalid_attributes }
        }.not_to change(Prompt, :count)
      end

      it "newテンプレートを再表示する" do
        post :create, params: { prompt: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET #edit" do
    let(:prompt) { create(:prompt, user: user) }

    before do
      get :edit, params: { id: prompt.id }
    end

    it "editテンプレートをレンダリングする" do
      expect(response).to render_template(:edit)
    end

    it "リクエストされたプロンプトを@promptに割り当てる" do
      expect(controller.instance_variable_get(:@prompt)).to eq(prompt)
    end
  end

  describe "PATCH #update" do
    let(:prompt) { create(:prompt, user: user) }
    let(:new_attributes) { { title: "Updated Title", url: "https://updated.example.com" } }

    context "有効なパラメータの場合" do
      before do
        patch :update, params: { id: prompt.id, prompt: new_attributes }
        prompt.reload
      end

      it "プロンプトの属性を更新する" do
        expect(prompt.title).to eq("Updated Title")
        expect(prompt.url).to eq("https://updated.example.com")
      end

      it "プロンプト詳細ページにリダイレクトする" do
        expect(response).to redirect_to(prompt)
      end

      it "フラッシュメッセージを表示する" do
        expect(flash[:notice]).to be_present
      end

      it "タグを更新する" do
        patch :update, params: { 
          id: prompt.id, 
          prompt: new_attributes.merge(tags_text: "tag4, tag5") 
        }
        prompt.reload
        expect(prompt.tags.count).to eq(2)
        expect(prompt.tags.map(&:name)).to include("tag4", "tag5")
      end

      it "タグを空にできる" do
        # まずタグを追加
        patch :update, params: { 
          id: prompt.id, 
          prompt: new_attributes.merge(tags_text: "tag4, tag5") 
        }
        prompt.reload
        expect(prompt.tags.count).to eq(2)
        
        # タグを空に更新
        patch :update, params: { 
          id: prompt.id, 
          prompt: new_attributes.merge(tags_text: "") 
        }
        prompt.reload
        expect(prompt.tags.count).to eq(0)
      end
    end

    context "無効なパラメータの場合" do
      before do
        patch :update, params: { id: prompt.id, prompt: invalid_attributes }
      end

      it "プロンプトを更新しない" do
        original_title = prompt.title
        prompt.reload
        expect(prompt.title).to eq(original_title)
      end

      it "editテンプレートをレンダリングする" do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:prompt) { create(:prompt, user: user) }

    it "プロンプトを削除する" do
      expect {
        delete :destroy, params: { id: prompt.id }
      }.to change(Prompt, :count).by(-1)
    end

    it "プロンプト一覧ページにリダイレクトする" do
      delete :destroy, params: { id: prompt.id }
      expect(response).to redirect_to(prompts_path)
    end
  end
end