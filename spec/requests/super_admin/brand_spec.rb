require 'rails_helper'

RSpec.describe SuperAdmin::BrandsController, type: :controller do
  describe 'Check login Super Admin' do
    let!(:super_admin) { User.find_by(role: 0) }

    let!(:admin) { User.find_by(role: 1) }

    context 'not login' do
      before { get :index }

      it 'redirect login' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'message should be login' do
        expect(flash[:alert]).to match(/Vui lòng đăng nhập hoặc đăng ký để tiếp tục/)
      end
    end

    context 'check login not super admin' do
      before :each do
        sign_in admin

        get :index
      end

      it 'redirect login' do
        expect(response).to redirect_to(root_path)
      end

      it 'message should not authorized' do
        expect(flash[:alert]).to match(/You are not authorized to access this page/)
      end
    end

    context 'check login role super admin ' do
      before :each do
        sign_in super_admin

        get :index
      end

      it 'should find just one product' do
        expect(assigns(:products)).to eq nil
      end

      it { should render_template(:index) }
    end
  end

  describe 'Create brand' do
    let!(:super_admin) { User.find_by(role: 0) }
    before :each do
      sign_in super_admin
    end

    context 'field required' do
      before :each do
        post :create, params: { brand: { name: '', domain: '' } }
      end

      it { expect(flash[:alert]).to be_present }

      it { expect(flash[:alert]).to match(/Name không thể để trắng/) }

      it { expect(flash[:alert]).to match(/Domain không thể để trắng/) }
    end

    it 'domain already exist' do
        Brand.create!(name: 'Thương hiệu', domain: 'dl' )
      post :create, params: { brand: { name: 'Thương hiệu', domain: 'dl' } }

      expect(flash[:alert]).to be_present
      expect(flash[:alert]).to match(/Domain đã tồn tại/)
    end

    it 'domain vali' do
      post :create, params: { brand: { name: 'Thương hiệu', domain: 'd_l' } }

      expect(flash[:alert]).to be_present
      expect(flash[:alert]).to match(/Domain không đúng định dạng/)
    end

    it 'create success' do
        post :create, params: { brand: { name: 'Thương hiệu', domain: 'th' } }

        expect(flash[:notice]).to be_present
        expect(response).to redirect_to(edit_super_admin_brand_path(Brand.last))
      end
  end
end
