# -*- coding: utf-8 -*-
require 'spec_helper'

describe ServiceCooperationsController do
  fixtures :products, :service_cooperations

  # コントローラーのチェック
  describe "exportメソッドのチェック" do
    it "DBからデータを取ってこれる" do
      get 'export', :url_file_name => service_cooperations(:one).url_file_name
      assigns[:service].should_not be_nil
    end
    it "正しいデータのURLファイル名なら404でない" do
      get 'export', :url_file_name => service_cooperations(:one).url_file_name
      response.should_not render_template("public/404.html")
    end
    it "要求するとファイルが返ってくる" do
      get 'export', :url_file_name => service_cooperations(:one).url_file_name
      response.should be_success
      response.headers['Content-Type'].should =~ %r(^application/octet-stream)
      response.headers['Content-Disposition'].should =~ %r(^attachment)
    end
    it "有効で無い場合には404" do
      get 'export', :url_file_name => service_cooperations(:close_service).url_file_name
      assigns[:service].should_not be_enable
      response.should render_template("public/404.html")
    end
    it "存在しないURLファイル名が渡された場合は404" do
      get 'export', :url_file_name => "nonexistent"
      assigns[:service].should be_nil
      response.should render_template("public/404.html")
    end
    it "URLファイル名が渡されなかった場合も404" do
      get 'export'
      response.should render_template("public/404.html")
    end
    it "SQLが正しくない場合も404" do
      get 'export', :url_file_name => service_cooperations(:sql_test).url_file_name
      response.should render_template("public/404.html")
    end
  end
end
