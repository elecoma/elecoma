require 'spec_helper'

describe Admin::ServiceCooperationsTemplatesController do

  fixtures :service_cooperations, :service_cooperations_templates, :products, :admin_users

  before do
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
  end

  describe "GET 'new'" do
    before do
      get 'new'
    end
    it "ページを表示できるか" do
      response.should be_success
    end
  end

  describe "POSE 'confirm' from 'new'" do
    before do
      service_cooperations_template_new_before_do
    end
    it "正しいデータの場合" do
      @service_template.should be_valid
      params = {
        :service_cooperations_template => @service_template.attributes
      }
      post 'confirm', params
      response.should render_template('confirm')
    end
    it "不正なデータの場合" do
      @service_template.template_name = nil
      @service_template.should_not be_valid
      params = {
        :service_cooperations_template => @service_template.attributes
      }
      post 'confirm', params
      response.should render_template('new')
    end
  end

  describe "POST 'create' レコードの追加" do
    before do
      service_cooperations_template_create_before_do
    end
    it "正しいデータの場合" do
      @service_template.should be_valid
      params = {
        :service_cooperations_template => @service_template.attributes
      }
      post 'create', params
      response.should redirect_to(:action => :index)
    end
    it "レコードが追加されたか" do
      params = {
        :service_cooperations_template => @service_template.attributes
      }
      template_length = ServiceCooperationsTemplate.all.length
      post 'create', params
      template_length.should == ServiceCooperationsTemplate.all.length - 1
    end
    it "追加されたレコードが正しい" do
      params = {
        :service_cooperations_template => @service_template.attributes
      }
      post 'create', params
      last_template = ServiceCooperationsTemplate.find(:last)
      last_template.template_name.should == @service_template.template_name
    end
    it "不正なデータの場合" do
      @service_template.template_name = nil
      @service_template.should_not be_valid
      params = {
        :service_cooperations_template => @service_template.attributes
      }
      post 'create',params
      response.should render_template(:new)
    end
  end

  describe "GET 'edit' 既存の要素を編集する" do
    before do
      get 'edit',:id => service_cooperations_templates(:one).id
    end
    it "リクエストは成功か" do
      response.should be_success
    end
    it "指定されたレコードをロードしているか" do
      assigns[:service_cooperations_template].should == service_cooperations_templates(:one)
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

  describe "POST 'confirm' from 'edit'" do
    before do
      service_cooperations_template_edit_before_do
    end
    it "正しいデータの場合" do
      @service_template.should be_valid
      params = {
        :service_cooperations_template => @service_template.attributes,
        :id => @service_template.id
      }
      post 'confirm', params
      response.should render_template(:confirm)
    end
    it "不正なデータの場合" do
      @service_template.template_name = nil
      @service_template.should_not be_valid
      params = {
        :service_cooperations_template => @service_template.attributes,
        :id => @service_template.id
      }
      post 'confirm', params
      response.should render_template(:edit)
    end
  end

  describe "POST 'update' レコードの更新" do
    before do
      service_cooperations_template_update_before_do
    end
    it "正しいデータの場合" do
      @service_template.should be_valid
      params = {
        :service_cooperations_template => @service_template.attributes,
        :id => @service_template.id
      }
      post 'update', params
      response.should redirect_to(:action => :index)
    end
    it "不正なデータの場合" do
      @service_template.template_name = nil
      @service_template.should_not be_valid
      params = {
        :service_cooperations_template => @service_template.attributes,
        :id => @service_template.id
      }
      post 'update', params
      response.should render_template(:edit)
    end
    it "更新されたことを確認" do
      one_id = service_cooperations_templates(:one).id
      params = {
        :service_cooperations_template => @service_template.attributes,
        :id => @service_template.id
      }
      ServiceCooperationsTemplate.find(one_id).template_name.should_not == 'test_update_template'
      post 'update', params
      ServiceCooperationsTemplate.find(one_id).template_name.should == 'test_update_template'
    end
    it "更新されたレコードが正確か" do
      one_id = service_cooperations_templates(:one).id
      params = {
        :service_cooperations_template => @service_template.attributes,
        :id => @service_template.id
      }
      post 'update', params
      @service_template.should == ServiceCooperationsTemplate.find(one_id)
    end
  end
 
  describe "GET 'index' 一覧を表示する" do
    before do
      get 'index'
    end
    it "ページを表示できるか" do
      response.should be_success
    end
    it "サービス一覧を取得することができるか" do
      assigns[:templates].should_not be_empty
    end
  end

  describe "GET 'destroy'" do
    it "レスポンスが正常か" do
      response.should be_success
    end
    it "レコードが１つ減ったか" do
      services_length = (ServiceCooperationsTemplate.all).length
      get 'destroy',:id => service_cooperations_templates(:one)
      services_length.should == (ServiceCooperationsTemplate.all).length + 1
    end
    it "意図したレコードが削除されたか" do
      ServiceCooperationsTemplate.find_by_id(service_cooperations_templates(:one)).should_not be_nil
      get 'destroy',:id => service_cooperations_templates(:one)
      ServiceCooperationsTemplate.find_by_id(service_cooperations_templates(:one)).should be_nil
    end
    it "無効なidの場合はレコード数は増減しない" do
      services_length = (ServiceCooperationsTemplate.all).length
      get 'destroy',:id => -1
      services_length.should == (ServiceCooperationsTemplate.all).length
    end
    it "無効なidの場合は警告文を表示" do
      get 'destroy',:id => -1
      flash[:notice].should == "削除に失敗しました 無効なidです"
    end
    it "無効なidの場合は'index'に飛ばす" do
      get 'destroy',:id => -1
      response.should redirect_to(:action => :index)
    end
  end
end

def service_cooperations_template_new_before_do
  get 'new'
  @service_template = assigns[:service_cooperations_template]
  @service_template.template_name = 'test_new_template'
  @service_template.description = '説明'
  @service_template.encode = 0
  @service_template.newline_character = 0
  @service_template.file_type = 0
end

def service_cooperations_template_edit_before_do
  get 'edit', :id => service_cooperations_templates(:one)
  @service_template = assigns[:service_cooperations_template]
  @service_template.template_name = 'test_update_template'
  @service_template.description = '設定'
end

def service_cooperations_template_create_before_do
  service_cooperations_template_new_before_do
  params = {
    :service_cooperations_template => @service_template.attributes
  }
  post 'confirm', params
  @service_template = assigns[:service_cooperations_template]
end

def service_cooperations_template_update_before_do
  service_cooperations_template_edit_before_do
  params = {
    :service_cooperations_template => @service_template.attributes,
    :id => @service_template.id
  }
  post 'confirm', params
  @service_template = assigns[:service_cooperations_template]
end

