require 'rails_helper'
require 'open-uri'

RSpec.describe SuperAdmin::ProductsController, driver: :selenium_chrome, js: true, type: :controller do
  describe "Super Admin Products" do
    let!(:product1) { Product.first }
    let!(:super_admin) { User.find_by(role: 0)  }
    let!(:admin) { User.find_by(role: 1) }
    let!(:params) do
      {
        q: {
          name_cont: 'Longan'
        },
        limit: 50
      }
    end

    context 'not login' do
      before { get :index, params: params }

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
        get :index,  params: params
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
        get :index,  params: params
      end

      it "should find just one product" do
        expect(assigns(:products)).to eq nil
      end
      it { should render_template(:index) }
    end

    context 'create products not have name' do
      before :each do
        sign_in super_admin
        post :create,  params: {product: {images: URI.open('https://bhd.1cdn.vn/files/library/images/site-1/20230527/web/ly-do-nen-an-man-30-105839.jpg')}}
      end

      it "show errors message" do
        expect(flash[:alert]).to be_present
      end

    end

    context 'create product have name' do
      before :each do
        sign_in super_admin
        post :create,  params: {product: {name: 'Hoa quả tự chọn' ,images: URI.open('https://bhd.1cdn.vn/files/library/images/site-1/20230527/web/ly-do-nen-an-man-30-105839.jpg')}}
      end


      it 'check data' do
        expect(Product.last.name).to match(/Hoa quả tự chọn/)
      end
      it { should redirect_to(edit_super_admin_product_path(Product.last)) }
      it {  expect(flash[:notice]).to be_present }

    end

    let(:file) { fixture_file_upload("#{Rails.root}/public/file_test/products.csv", 'application/csv') }
    let(:service) { ImportDataCsvService.new(file, super_admin,  super_admin.brand_id) } 
    let(:service_class) { ImportDataCsvService }

    context 'create product by file ' do 
      before :each do
        sign_in super_admin
        post :import,  params: {file: file, commit: "Nhập Ngay"}
      end

      it 'call service' do
        expect(service.import_products).to eq(["Nhập hàng thành công"])
      end

  
      it { should render_template(:import) }

      it 'check message' do
        expect(assigns(:message).first).to match(/Nhập hàng thành công/)
      end
    end

    context "a context" do
      
      it 'call job with pram' do 
        sign_in super_admin
        expect(InventoryProductJob).to receive(:perform_later).with('import_products', {file: File.join("#{Rails.root}/public/file_upload", "#{Time.now.to_i}_#{file.original_filename}"),  user: super_admin, brand: super_admin.brand_id})
        post :import,  params: {file: file, commit: "Xếp hàng đợi"}
      end

    end
    

    context 'create product by file ' do 
      before :each do
        sign_in super_admin
        post :import,  params: {file: file, commit: "Xếp hàng đợi"}
      end

      it 'save file upload' do
        expect(File.directory?("#{Rails.root}/public/file_upload")).to be true
        expect(File).to exist(File.join("#{Rails.root}/public/file_upload", "#{Time.now.to_i}_#{file.original_filename}"))
      end

      it { should render_template(:import) }

      it 'check message' do
        expect(assigns(:message).first).to match(/File của bạn đã được lưu và xếp vào hàng đợi. Hệ thống sẽ thông báo cho bạn khi hoàn thành/)
      end
    end

  end
end
