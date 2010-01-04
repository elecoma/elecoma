require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::CustomersController do
  fixtures :authorities, :functions, :admin_users
  fixtures :customers
  before(:each) do
    session[:admin_user] = admin_users(:admin_user_00011)
    @customer = customers :customer_management
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
  end

  it "should use Admin::CustomersController" do
    controller.should be_an_instance_of(Admin::CustomersController)
  end
  
  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end
  
  describe "GET 'search'" do
    before do
    end
    
    it "should be successful" do
      get 'search'
      response.should be_success
    end
    
    it "顧客コード" do
      get 'search', :condition => {:customer_code => "yamada"}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:customers].should be_any do |record|
        record.id == @customer.id
      end
    end
    
    it "都道府県" do
      get 'search', :condition => {:prefecture_id => 13}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:customers].should be_any do |record|
        record.id == @customer.id
      end
    end
    
    it "顧客名（姓）" do
      get 'search', :condition => {:customer_name_kanji => "山田"}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:customers].should be_any do |record|
        record.id == @customer.id
      end
    end
    
    it "顧客名（名）" do
      get 'search', :condition => {:customer_name_kanji => "太郎"}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:customers].should be_any do |record|
        record.id == @customer.id
      end
    end

    it "性別" do
      get 'search', :condition => {:sex_male => 1}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:customers].should be_any do |record|
        record.id == @customer.id
      end
    end

    it "誕生月" do
      get 'search', :condition => {:birth_month => 8}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:customers].should be_any do |record|
        record.id == @customer.id
      end
    end

    it "誕生日" do
      get 'search', :condition => {:birthday_from => Date.new(1995,8,20), :birthday_to => Date.new(1995,8,20)}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:customers].should be_any do |record|
        record.id == @customer.id
      end
    end

    it "メールアドレス" do
      get 'search', :condition => {:email => "yamada@kbmj.com"}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:customers].should be_any do |record|
        record.id == @customer.id
      end
      assigns[:customers][0].full_name.should_not be_nil
    end

    it "電話番号" do
      get 'search', :condition => {:tel_no => "0352992102"}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:customers].should be_any do |record|
        record.id == @customer.id
      end
    end

    it "職業" do
      get 'search', :condition => {:occupation_id => [1]}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:customers].should be_any do |record|
        record.id == @customer.id
      end
    end

  end
  
  describe "GET 'edit'" do
    it "should be successful" do
      get 'edit', {:id=>1}
      response.should be_success
      assigns[:customer].should == Customer.find(1)
    end
  end
 
  describe "POST 'confirm'" do
    it "should be successful" do
      @customer.zipcode02 = "0123"
      customer = @customer.attributes
      post 'confirm', :id => @customer.id, :customer => customer, :order_count => 0
      response.should render_template("admin/customers/confirm.html.erb")
    end
  end

  describe "POST 'update'" do
    it "should be successful" do
      @customer.zipcode02 = "0123"
      customer = @customer.attributes
      post 'update', :id => @customer.id, :customer => customer, :order_count => 0
      response.should redirect_to(:action => :index)
    end
  end


  describe "POST 'csv_download'" do
    it "should be successful" do
      condition = {:customer_id => @customer.id}
      post 'csv_download', :condition => condition
      flash[:notice].should be_nil
      response.should_not render_template("admin/customers/index.html.erb")
      response.body.should_not be_nil
    end

    it "件数なしのパターン" do
      condition = {:customer_id => 34241234231432}
      post 'csv_download', :condition => condition
      response.should render_template("admin/customers/index.html.erb")
    end
  end

  describe "POST 'csv_upload'" do
    it "should be successful" do
      last_customer = Customer.find(:last)
      csv = uploaded_file(File.dirname(__FILE__) + "/../../customer_upload.csv", "text", "customer_upload.csv")
      post 'csv_upload', :upload_file => csv
      Customer.find(:last).should_not == last_customer
    end

    it "ファイルを与えてない場合" do
      last_customer = Customer.find(:last)
      post 'csv_upload', :uploaded_file => ""
      Customer.find(:last).should == last_customer
    end
  end

end



