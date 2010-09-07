# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PaymentPlugin do
  fixtures :payment_plugins, :payments
  
  it "有効なプラグインだけ取得できる" do
    payment_plugin = payment_plugins(:disable_normal_plugin)
    plugin_instance = payment_plugin.get_plugin_instance
    plugin_instance.should be_nil
    payment_plugin = payment_plugins(:load_normal_plugin)
    plugin_instance = payment_plugin.get_plugin_instance
    plugin_instance.should_not be_nil
    plugin_instance.should be_an_instance_of(NormalPaymentPlugin)
  end

  describe "必須条件テスト" do
    before do
      @payment_plugin = payment_plugins(:disable_normal_plugin)
    end
    it "正しい条件" do
      @payment_plugin.should be_valid
    end

    it "名前が必須" do
      @payment_plugin.name = nil
      @payment_plugin.should_not be_valid
    end

    it "モデル名が必須" do
      @payment_plugin.model_name = nil
      @payment_plugin.should_not be_valid
    end
    
    it "詳細が必須" do
      @payment_plugin.detail = nil
      @payment_plugin.should_not be_valid
    end
    
  end
  
  it "モデルがインスタンス化できないものは登録できない" do
    payment_plugin = payment_plugins(:disable_normal_plugin)
    payment_plugin.model_name = "NotFoundPaymentPlugin"
    payment_plugin.should_not be_valid
    payment_plugin.model_name = "NormalPaymentPlugin"
    payment_plugin.should be_valid
  end

end

