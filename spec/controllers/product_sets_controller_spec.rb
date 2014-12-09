   # -*- coding: utf-8 -*-
   require File.dirname(__FILE__) + '/../spec_helper'
   
describe Admin::ProductSetsController, :type => :controller do
  fixtures :admin_users, :products, :categories, :seos, :product_styles, :styles, :style_categories, :shops
  before do
    @controller.class.skip_before_filter @controller.class.before_filters
    @controller.class.skip_after_filter @controller.class.after_filters
    session[:admin_user] = admin_users(:admin10)
  end
  
  it 'search res success' do
    get :search
    response.should be_success
  end
end
