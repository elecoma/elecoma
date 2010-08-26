# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NormalPaymentPlugin do
  fixtures :payment_plugins
  
  it "標準モジュール読み込み" do
    np = payment_plugins(:load_normal_plugin)
    np.model_name.classify.should == "NormalPaymentPlugin"
    instance = np.get_plugin_instance
    instance.should_not be_nil
    instance.should be_an_instance_of(NormalPaymentPlugin)
  end
end

