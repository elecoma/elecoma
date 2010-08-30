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

  describe "モジュールメソッドの確認" do
    before do
      @np = payment_plugins(:load_normal_plugin).get_plugin_instance
    end

    it "confirmメソッド" do
      @np.complete.should == :before_finish
    end

    it "next_stepメソッド" do
      @np.next_step(:complete).should == :before_finish
      lambda{@np.next_step(:finish)}.should raise_error(RuntimeError, '遷移がありません')
    end
  end
end

