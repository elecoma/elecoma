require 'spec_helper'

describe Admin::ServiceCooperationsController do
  fixtures :service_cooperations, :service_cooperations_templates, :products, :admin_users
  
  before do
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter :admin_permission_check_template
  end

  describe "GET 'index'管理画面サービス一覧ページ" do
    before do
      get 'index'
    end
    it "トップページの表示" do
      response.should be_success
    end
    it "サービス一覧を取得できるか" do
      servicelist = assigns[:services] # 複数形
      servicelist.should_not be_empty
    end
  end

  describe "GET new" do
    it "リクエストは成功か" do
      get 'new'
      response.should be_success
    end
  end

  describe "POST 'confirm' from new" do
    before do
      service_cooperations_new_before_do
    end
    it "正しいデータの場合" do
      @service_cooperation.should be_valid
      params = {
        :service_cooperation => @service_cooperation.attributes
      }
      post 'confirm', params
      response.should render_template('confirm')
    end
    it "不正なデータの場合" do
      @service_cooperation.name = nil 
      @service_cooperation.should_not be_valid
      params = {
        :service_cooperation => @service_cooperation.attributes
      }
      post 'confirm', params
      response.should render_template('new')
    end
  end

  describe "POST 'create' レコードの追加" do
    before do
      service_cooperations_create_before_do
    end
    it "正しいデータの時" do
      @service_cooperation.should be_valid
      params = {
        :service_cooperation => @service_cooperation.attributes
      }
      post 'create', params
      response.should redirect_to(:action => :index)
    end
    it "追加されたことを確認" do
      params = {
        :service_cooperation => @service_cooperation.attributes
      }
      length = ServiceCooperation.all.length
      post 'create', params
      length.should == ServiceCooperation.all.length - 1
    end
    it "追加されたレコードが正確か" do
      params = {
        :service_cooperation => @service_cooperation.attributes
      }
      post 'create', params
      service = ServiceCooperation.find(:last)
      service.sql.should == @service_cooperation.sql
      service.name.should == @service_cooperation.name
    end
    it "不正なデータの場合" do
      @service_cooperation.name = nil
      @service_cooperation.should_not be_valid
      params = {
        :service_cooperation => @service_cooperation.attributes
      }
      length = ServiceCooperation.all.length
      post 'create', params
      length.should == ServiceCooperation.all.length
      response.should render_template("new")
    end
  end

  describe "GET 'edit' レコードの編集" do
    before do
      get 'edit', :id => service_cooperations(:one).id
    end
    it "リクエストは成功か" do
      response.should be_success
    end
    it "指定されたレコードをロードしているか" do
      assigns[:service_cooperation].should == service_cooperations(:one)
    end
    it "無効なidを渡された場合 警告文の表示" do
      get 'edit',:id => -1
      flash[:notice].should == "無効なidが渡されました"
    end
    it "無効なidを渡された場合 'index'に飛ばす" do
      get 'edit',:id => -1
      response.should redirect_to(:action => :index)
    end
  end

  describe "POST 'confirm' from edit" do
    before do
      service_cooperations_edit_before_do
    end
    it "正しいデータの場合" do
      @service_cooperation.should be_valid
      params = {
        :service_cooperation => @service_cooperation.attributes,
        :id => @service_cooperation.id
      }
      post 'confirm', params
      response.should render_template('confirm')
    end
    it "不正なデータの場合" do
      @service_cooperation.name = nil
      @service_cooperation.should_not be_valid
      params = {
        :service_cooperation => @service_cooperation.attributes,
        :id => @service_cooperation.id
      }
      post 'confirm', params
      response.should render_template('edit')
    end
  end

  describe "POST 'update'" do
    before do
      service_cooperations_update_before_do
    end
    it "正しいデータの場合" do
      @service_cooperation.should be_valid
      params = {
        :service_cooperation => @service_cooperation.attributes,
        :id => @service_cooperation.id
      }
      post 'update', params
      response.should redirect_to(:action => :index)
    end
    it "更新されたことを確認" do
      one_id = service_cooperations(:one).id
      params = {
        :service_cooperation => @service_cooperation.attributes,
        :id => @service_cooperation.id
      }
      ServiceCooperation.find(one_id).name.should_not == "super_test_name"
      post 'update', params
      ServiceCooperation.find(one_id).name.should == "super_test_name"
    end
    it "更新されたレコードが正確か" do
      one_id = service_cooperations(:one).id
      params = {
        :service_cooperation => @service_cooperation.attributes,
        :id => @service_cooperation.id
      } 
      post 'update', params
      @service_cooperation.should == ServiceCooperation.find(one_id)
    end
    it "不正なデータの場合" do
      @service_cooperation.name = nil
      @service_cooperation.should_not be_valid
      params = {
        :service_cooperation => @service_cooperation.attributes,
        :id => @service_cooperation.id
      }
      post 'update', params
      response.should render_template(:edit)
    end
  end

  describe "GET 'destroy'" do
    it "レコードが１つ減ったか" do
      services_length = (ServiceCooperation.all).length
      get 'destroy', :id => service_cooperations(:one)
      services_length.should == (ServiceCooperation.all).length + 1
    end
    it "意図したレコードが削除されたか" do
      ServiceCooperation.find_by_id(service_cooperations(:one).id).should_not be_nil
      get 'destroy', :id => service_cooperations(:one).id
      ServiceCooperation.find_by_id(service_cooperations(:one).id).should be_nil
    end
    it "無効なidの場合はレコード数は増減しない" do
      services_length = (ServiceCooperation.all).length
      get 'destroy', :id => -1
      services_length.should == (ServiceCooperation.all).length
    end
    it "無効なidの場合は警告文を表示" do
      get 'destroy', :id => -1
      flash[:notice].should == "削除に失敗しました 無効なidです"
    end
    it "無効なidの場合は'index'に飛ばす" do
      get 'destroy',:id => -1
      response.should redirect_to(:action => :index)
    end
  end
end


def service_cooperations_new_before_do
  get 'new'
  @service_cooperation = assigns[:service_cooperation]
  @service_cooperation.name = 'testservice'
  @service_cooperation.enable = true
  @service_cooperation.url_file_name = 'file_output'
  @service_cooperation.file_type = 0
  @service_cooperation.encode = 0
  @service_cooperation.newline_character = 0
  @service_cooperation.field_items = 'test'
  @service_cooperation.sql = 'test'
end

def service_cooperations_edit_before_do
  get 'edit', :id => service_cooperations(:one).id
  @service_cooperation = assigns[:service_cooperation]
  @service_cooperation.name = "super_test_name"
end

def service_cooperations_create_before_do
  service_cooperations_new_before_do
  params = {
    :service_cooperation => @service_cooperation.attributes
  }
  post 'confirm', params
  @service_cooperation = assigns[:service_cooperation]
end

def service_cooperations_update_before_do
  service_cooperations_edit_before_do
  params = {
    :service_cooperation => @service_cooperation.attributes,
    :id => @service_cooperation.id
  }
  post 'confirm', params
  @service_cooperation = assigns[:service_cooperation]
end
