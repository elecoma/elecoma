# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PluginsController do
  fixtures :admin_users
  fixtures :payment_plugins
  
  before do
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
  end

  it "should use Admin::PluginsController" do
    controller.should be_an_instance_of(Admin::PluginsController)
  end

  describe "index を表示した時に " do
    it "成功する" do
      get 'index'
      response.should be_success
      assigns[:payment_plugins].should_not be_nil
    end
  end

  describe "決済プラグイン新規作成を " do
    it "表示できる" do
      get 'new_payment_plugin'
      response.should be_success
      assigns[:payment_plugin].should_not be_valid
    end
  end

  describe "決済プラグイン新規作成から確認画面へ遷移して " do
    before do
      get 'new_payment_plugin'
      @payment_plugin = assigns[:payment_plugin]
      @payment_plugin.name = "テストプラグイン"
      @payment_plugin.model_name = "NormalPaymentPlugin"
      @payment_plugin.detail = "テストプラグインの詳細"
      @payment_plugin.enable = true
    end

    it "正しいデータの場合は成功" do
      params = {
        :payment_plugin => @payment_plugin.attributes,
        :id => nil
      }
      post 'confirm_payment_plugin', params
      response.should render_template('confirm_payment_plugin')
    end

    it "不正なデータの場合は決済プラグイン新規作成に戻る" do
      @payment_plugin.model_name = "NotFoundPaymentPlugin"
      params = {
        :payment_plugin => @payment_plugin.attributes,
        :id => nil
      }
      post 'confirm_payment_plugin', params
      response.should render_template("new_payment_plugin")
    end

  end
  
  describe "決済プラグイン新規作成で確認画面から完了へ遷移するとき " do
    before do
      @payment_plugin = PaymentPlugin.new
      @payment_plugin.name = "テストプラグイン"
      @payment_plugin.model_name = "NormalPaymentPlugin"
      @payment_plugin.detail = "テストプラグインの詳細"
      @payment_plugin.enable = true
    end

    it "正常なデータの時はindexへ遷移する" do
      params = {
        :payment_plugin => @payment_plugin.attributes,
        :id => nil
      }
      post 'create_payment_plugin', params
      response.should redirect_to(:action => :index)
    end

    it "異常なデータの時は新規作成入力画面に戻る" do
      @payment_plugin.model_name = "NotFoundPaymentPlugin"
      params = {
        :payment_plugin => @payment_plugin.attributes,
        :id => nil
      }
      post 'create_payment_plugin', params
      response.should render_template("new_payment_plugin")
    end
  end

  describe "決済プラグイン編集画面へ遷移して " do
    
    it "存在するプラグインを指定すれば正常にできる" do
      payment_plugin = payment_plugins(:load_normal_plugin)
      get 'edit_payment_plugin', :id => payment_plugin.id
      response.should render_template("edit_payment_plugin")
    end

    it "存在しないプラグインを指定したらindexへ遷移する" do
      not_payment_plugin_id = PaymentPlugin.find(:last, :order => :id).id + 1000
      get 'edit_payment_plugin', :id => not_payment_plugin_id
      response.should redirect_to(:action => :index)
    end

  end
  
  describe "決済プラグイン編集画面から確認画面へ遷移して " do
    before do
      @payment_plugin = payment_plugins(:load_normal_plugin)
    end
    
    it "正しいデータの場合は成功" do
      @payment_plugin.name = "テストプラグイン"
      params = {
        :payment_plugin => @payment_plugin.attributes, 
        :id => @payment_plugin.id
      }
      post 'confirm_payment_plugin', params
      response.should render_template('confirm_payment_plugin')
    end

    it "不正なデータの場合は決済プラグイン編集画面に戻る" do
      @payment_plugin.model_name = "NotFoundPaymentPlugin"
      params = {
        :payment_plugin => @payment_plugin.attributes, 
        :id => @payment_plugin.id
      }
      post 'confirm_payment_plugin', params
      response.should render_template("edit_payment_plugin")
    end
  end

  describe "決済プラグイン編集で確認画面から完了へ遷移するとき " do
    before do
      @payment_plugin = payment_plugins(:load_normal_plugin)
    end
    
    it "正常なデータの時はindexへ遷移する" do
      params = {
        :payment_plugin => @payment_plugin.attributes
      }
      post 'update_payment_plugin', params
      response.should redirect_to(:action => :index)
    end

    it "異常なデータの時は編集画面に戻る" do
      @payment_plugin.model_name = "NotFoundPaymentPlugin"
      params = {
        :payment_plugin => @payment_plugin.attributes
      }
      post 'update_payment_plugin', params
      response.should render_template("edit_payment_plugin")
    end

  end

  describe "決済モジュールの設定画面への遷移は " do
    before do
      @r = PaymentPlugin.new
      @r.name = "Test Payment Plugin"
      @r.model_name = "TestPaymentPlugin"
      @r.detail = "Test Payment Plugin Detail"
      @r.enable = true
      @r.save
    end
    
    it "NormalPaymentPluginは設定画面がないのでindexに戻る" do
      payment_plugin = payment_plugins(:load_normal_plugin)
      get 'edit_payment_plugin_config', :id => payment_plugin.id
      response.should redirect_to(:action => :index)
    end

    it "TestPaymentPluginは設定画面にリダイレクトする" do
      get 'edit_payment_plugin_config', :id => @r.id
      response.should redirect_to(:action => :test_payment_plugin_config)
    end
  end

  describe "テストモック" do
    it "test_payment_plugin_config" do
      get 'test_payment_plugin_config'
      response.should be_success
    end
    it "test_payment_plugin_config_confirm" do
      get 'test_payment_plugin_config_confirm'
      response.should be_success
    end
    it "test_payment_plugin_config_complete" do
      get 'test_payment_plugin_config_complete'
      response.should be_success
    end
    it "test_payment_plugin_config_no_action" do
      lambda{
        get 'test_payment_plugin_config_no_action'
      }.should raise_error(ActionController::UnknownAction)
    end
  end

end

#テスト決済モジュール
class TestPaymentPlugin < ActiveForm
  include PaymentPluginBase
  
  def has_config?
    true
  end

  def config
    return :test_payment_plugin_config
  end

end

module Admin
  module PluginsControllerExtend

    def test_payment_plugin_config
    end

    def test_payment_plugin_config_confirm
    end

    def test_payment_plugin_config_complete
    end

  end
end

