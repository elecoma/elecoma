# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

class DummyController < BaseController
  skip_before_filter :start_transaction
  skip_after_filter :end_transaction

  def exception_to_activerecord_recordnotfound
    rescue_action_in_public ActiveRecord::RecordNotFound.new
  end

  def exception_to_nameerror
    rescue_action_in_public NameError.new
  end
end

describe BaseController do
  fixtures :carts, :customers, :shops, :product_styles

  before do
    @controller.class.skip_before_filter :start_transaction
    @controller.class.skip_after_filter :end_transaction
  end

  #Delete this example and add some real ones
  it "should use BaseController" do
    controller.should be_an_instance_of(BaseController)
  end

  describe "セッション" do
     before(:each) do
       time_now = Time.now
       Time.stub!(:now).and_return(time_now)
       session[:customer_id] = 1
     end

     it "一定時間ページをリロードしないとセッションリセット" do
       session[:expires_time] = Time.now - BaseController::EXPIRES_TIME
       controller.instance_eval{load_user}
       session[:customer_id].should be_nil
    end
  end

  describe "cart_total_prices" do
    it "should have products with any prices in a cart " do
      carts = customers(:have_cart_user).carts
      result = controller.cart_total_prices carts
      result.should > 0
    end
  end

  describe "rescue_action_in_public" do
    before do
      @controller = DummyController.new
    end
    it "exception is Active::RecordNotFound should render 404" do
      get 'exception_to_activerecord_recordnotfound'
      response.should render_template("public/404.html")
    end
    it "exception is NameError should render 500" do
      get 'exception_to_nameerror'
      response.should render_template("public/500.html")
    end
    it "exception is Active::RecordNotFound should render 404(mobile)" do
      request.user_agent = "DoCoMo/2.0 SH903i(c100;TB;W24H16)"
      get 'exception_to_activerecord_recordnotfound'
      response.should render_template("public/404_mobile.html")
    end
    it "exception is NameError should render 500(mobile)" do
      request.user_agent = "DoCoMo/2.0 SH903i(c100;TB;W24H16)"
      get 'exception_to_nameerror'
      response.should render_template("public/500_mobile.html")
    end
  end
end
