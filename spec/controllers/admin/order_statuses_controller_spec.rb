require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::OrderStatusesController do
  fixtures :order_deliveries, :authorities, :functions, :admin_users, :orders
  before do 
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
  end
  
  #Delete this example and add some real ones
  it "should use Admin::OrderStatusesController" do
    controller.should be_an_instance_of(Admin::OrderStatusesController)
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end

    it "admin/order_statuses/index を表示する" do
      get 'index'
      response.should render_template("admin/order_statuses/index.html.erb")
    end

    it "未指定だと新規受付を表示" do
      get 'index'
      assigns[:order_deliveries].each do | record |
        record.status.should == OrderDelivery::YOYAKU_UKETSUKE
        record.order.retailer_id.should == 1
      end
    end

    it "選んだステータスの一覧" do
      status = 2
      get 'index', :select => status
      assigns[:order_deliveries].each do |record|
        record.status.should == status
        record.order.retailer_id.should == 1
      end
    end

    it "ID の降順で表示" do
      prev_id = nil
      get 'index'
      assigns[:order_deliveries].each do |record|
        record.id.should < prev_id if prev_id
        prev_id = record.id
        record.order.retailer_id.should == 1
      end
    end
  end

  describe "GET 'index'を違うショップがやった場合" do
    before do 
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
    end

    it "should be successful" do
      get 'index'
      response.should be_success
    end

    it "admin/order_statuses/index を表示する" do
      get 'index'
      response.should render_template("admin/order_statuses/index.html.erb")
    end

    it "未指定だと新規受付を表示" do
      get 'index'
      assigns[:order_deliveries].each do | record |
        record.status.should == OrderDelivery::YOYAKU_UKETSUKE
        record.order.retailer_id.should == 2
      end
    end

    it "選んだステータスの一覧" do
      status = 2
      get 'index', :select => status
      assigns[:order_deliveries].each do |record|
        record.status.should == status
        record.order.retailer_id.should == 2
      end
    end

    it "ID の降順で表示" do
      prev_id = nil
      get 'index'
      assigns[:order_deliveries].each do |record|
        record.id.should < prev_id if prev_id
        prev_id = record.id
        record.order.retailer_id.should == 2
      end
    end
  end


  describe "GET 'update'" do
    it "/ にリダイレクトする" do
      post 'update', :new_status => 3, :id_array => %w(1), :order_delivery_ticket_code => {"1" => "Test"}
      response.should redirect_to(:action => "index")
    end

    it "選択した受注のステータスを変える" do
      order_delivery_ticket_code = {"1" => "Test", "11" => "Test"}
      post 'update', :new_status => 3, :id_array => %w(1 11), :order_delivery_ticket_code => order_delivery_ticket_code
      OrderDelivery.find(1, 11).each do | record |
        record.status.should == 3
      end
    end

    it "別のショップから受注のステータスは変更できない" do
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
      order_delivery_ticket_code = {"1" => "Test", "11" => "Test"}
      post 'update', :new_status => 3, :id_array => %w(1 11), :order_delivery_ticket_code => order_delivery_ticket_code
      OrderDelivery.find(1, 11).each do | record |
        record.status.should_not == 3
      end
      flash[:status_e].should_not be_blank
    end


  end

  describe "POST 'csv_upload'" do
    it "should be successful" do
      csv = uploaded_file(File.dirname(__FILE__) + "/../../csv/order_status_update.csv", "text", "order_status_update.csv")
      post 'csv_upload', :upload_file => csv
      flash[:status].should_not be_nil
      flash[:has_error].should be_nil
    end
    
    it "別のショップは自分以外へのショップへCSVアップロードはできない" do 
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)      
      csv = uploaded_file(File.dirname(__FILE__) + "/../../csv/order_status_update.csv", "text", "order_status_update.csv")
      post 'csv_upload', :upload_file => csv
      flash[:has_error].should be_true
    end

    it "別のショップは自分のショップに対してはアップロードはできる" do
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)      
      csv = uploaded_file(File.dirname(__FILE__) + "/../../csv/order_status_update_other_shop.csv", "text", "order_status_update.csv")
      post 'csv_upload', :upload_file => csv
      flash[:status].should_not be_nil
      flash[:has_error].should be_nil
    end
    
    it "マスターショップであっても別のショップへはCSVアップロードはできない" do 
      csv = uploaded_file(File.dirname(__FILE__) + "/../../csv/order_status_update_other_shop.csv", "text", "order_status_update.csv")
      post 'csv_upload', :upload_file => csv
      flash[:has_error].should be_true
    end


  end

end
