# -*- coding: utf-8 -*-
require 'spec_helper'

describe Admin::StockBaseController do
  fixtures :admin_users,:products,:product_styles,:suppliers
  fixtures :categories

  before do 
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter    
  end
  describe "GET 'search'" do
   
    it "should be successful" do
      get 'search'
      response.should be_success
    end
    
    it "商品ID" do
      get 'search', :condition => {:product_id => '16'}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:product_styles].size.should == 1
      assigns[:product_styles][0].attributes.should == product_styles(:valid_product).attributes     
    end
    
    it "商品コード" do
      get 'search', :condition => {:code => '001'}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:product_styles].size.should == 2
      assigns[:product_styles][0].attributes.should == product_styles(:valid_product).attributes
      assigns[:product_styles][1].attributes.should == product_styles(:campaign_product).attributes       
    end
    
    it "商品名" do
      get 'search', :condition => {:name => "スカート"}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:product_styles].size.should == 5
      assigns[:product_styles][0].attributes.should == product_styles(:campaign_product).attributes
      assigns[:product_styles][1].attributes.should == product_styles(:sell_stop_product).attributes
      assigns[:product_styles][2].attributes.should == product_styles(:multi_styles_product_1).attributes
      assigns[:product_styles][3].attributes.should == product_styles(:multi_styles_product_2).attributes
      assigns[:product_styles][4].attributes.should == product_styles(:multi_styles_product_3).attributes
    end
    
    it "商品型番" do
      get 'search', :condition => {:manufacturer => "001"}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:product_styles].size.should == 0
    end

    it "仕入先名" do
      get 'search', :condition => {:supplier => "2"}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:product_styles].size.should == 1
      assigns[:product_styles][0].attributes.should == product_styles(:valid_product).attributes      
    end
    it "カテゴリ" do
      get 'search', :condition => {:category => "16"}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:product_styles].size.should == 1
      assigns[:product_styles][0].attributes.should == product_styles(:valid_product).attributes      
    end 
    it "登録日・更新日" do
      get 'search', :condition => {:updated_at_from => "2009-10-01",:updated_at_to=>"2009-10-01"}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:product_styles].size.should == 1
      assigns[:product_styles][0].attributes.should == product_styles(:valid_product).attributes      
    end      

    it "販売元が商品を持っていない時に検索すると空になる" do
      session[:admin_user] = admin_users(:admin17_retailer_id_is_fails)
      get 'search', :condition => {}
      assigns[:product_styles].should == []
    end


  end
end
