require 'rails_helper'

RSpec.describe SuperAdmin::UsersController, type: :controller do
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

  describe 'Create new users' do
    let!(:super_admin) { User.find_by(role: 0) }

    before :each do
      sign_in super_admin
    end

    context 'field required' do
      before :each do
        post :create, params: { user: { address: 'test' } }
      end

      it { expect(flash[:alert]).to be_present }

      it { expect(flash[:alert]).to match(/Name không thể để trắng/) }

      it { expect(flash[:alert]).to match(/Email không thể để trắng/) }

      it { expect(flash[:alert]).to match(/Phone không thể để trắng/) }

      it { expect(flash[:alert]).to match(/Role không thể để trắng/) }

      it { should render_template(:new) }
    end

    context 'phone and email uniq' do
      before :each do
        post :create,
             params: { user: { name: 'Name Test', phone: super_admin.phone, email: super_admin.email, brand_id: 1,

                               address: 'test' } }
      end

      it { expect(flash[:alert]).to be_present }

      it { expect(flash[:alert]).to match(/Email đã tồn tại/) }

      it { expect(flash[:alert]).to match(/Phone đã tồn tại/) }

      it { should render_template(:new) }
    end

    context ' create user success' do
      before :each do
        post :create, params: { user: { name: 'Name Test', phone: '038889870', email: 'nam_rspec_prefix@gmail.com', brand_id: 1,

                                        role: 'super_admin' } }
      end

      it 'show message and redirect' do
        expect(flash[:notice]).to be_present
        expect(flash[:notice]).to match(/Tạo người dùng thành công/)
        expect(response).to redirect_to(edit_super_admin_user_path(User.last))
      end
    end
  end

  describe 'Update password' do
    let!(:super_admin) { User.find_by(role: 0) }
    before :each do
      sign_in super_admin
      @user = User.last
    end

    context 'password confirm' do
      before :each do
        patch :update, params: { id: @user.id, user: { password: '061020', password_confirmation: '123456' } }
      end

      it { expect(flash[:alert]).to be_present }

      it { expect(flash[:alert]).to match(/Password confirmation không khớp với xác nhận/) }
    end
  end
end
