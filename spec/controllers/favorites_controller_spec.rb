# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FavoritesController do
  fixtures :favorites,:product_styles

  before do
    @controller.class.skip_before_filter :start_transaction
    @controller.class.skip_after_filter :end_transaction
  end

  describe "POST add_favorite" do
    before do
      @exists_favorite = favorites(:exists_favorite)
    end

    it "リクエストは成功する" do
      response.should be_true
    end

    describe "product_style_idが無く、ログインしていない場合" do
      it "お気に入り一覧へリダイレクトする" do
        post 'add_favorite', params={}
        response.should redirect_to controller: :accounts, action: :login
      end

      it "お気に入りが増えていない" do
        lambda{
          post 'add_favorite', params = {}
        }.should_not change(Favorite,:count).by(1)
      end
    end

    describe "product_style_idが無く、ログインしている場合" do
      before do
        session[:customer_id] = @exists_favorite.customer_id
      end

      it "お気に入り一覧へリダイレクトする" do
        post 'add_favorite', params={}
        response.should redirect_to controller: :accounts, action: :favorite
      end

      it "お気に入りが増えていない" do
        lambda{
          post 'add_favorite', params = {}
        }.should_not change(Favorite,:count).by(1)
      end
    end

    describe "product_style_idがあり、ログインしていない場合" do
      it "お気に入り一覧へリダイレクトする" do
        post 'add_favorite', params={product_style_id: @exists_favorite.product_style_id}
        response.should redirect_to controller: :accounts, action: :login
      end

      it "お気に入りが増えていない" do
        lambda{
          post 'add_favorite', params = { product_style_id: @exists_favorite.product_style_id }
        }.should_not change(Favorite,:count).by(1)
      end
    end

    describe "product_style_idがあり、ログインしている場合" do
      before do
        session[:customer_id] = @exists_favorite.customer_id
      end

      describe "既にお気に入りに入れている商品の場合" do
        it "お気に入り一覧へリダイレクトする" do
          post 'add_favorite', params = { product_style_id: @exists_favorite.product_style_id }
          response.should redirect_to controller: :accounts, action: :favorite
        end

        it "お気に入りが増えていない" do
          lambda{
            post 'add_favorite', params = { product_style_id: @exists_favorite.product_style_id }
          }.should_not change(Favorite,:count).by(1)
        end
      end

      describe "まだお気に入りに入れていない商品の場合" do
        before do
          @product_style = product_styles(:valid_product)
        end

        it "お気に入り一覧へリダイレクトする" do
          post 'add_favorite', params = { product_style_id: @product_style.id }
          response.should redirect_to controller: :accounts, action: :favorite
        end

        it "お気に入りが増えている" do
          lambda{
            post 'add_favorite', params = { product_style_id: @product_style.id }
          }.should change(Favorite,:count).by(1)
        end
      end
    end
  end

  describe "POST delete_favorite" do
    before do
      @exists_favorite = favorites(:exists_favorite)
    end

    it "リクエストは成功する" do
      response.should be_true
    end

    describe "product_style_idsが無く、ログインしていない場合" do
      it "お気に入り一覧へリダイレクトする" do
        post 'delete_favorite', params={}
        response.should redirect_to controller: :accounts, action: :login
      end

      it "お気に入りが減っていない" do
        lambda{
          post 'delete_favorite', params = {}
        }.should_not change(Favorite,:count).by(-1)
      end
    end

    describe "product_style_idsが無く、ログインしている場合" do
      before do
        session[:customer_id] = @exists_favorite.customer_id
      end

      it "お気に入り一覧へリダイレクトする" do
        post 'delete_favorite', params={}
        response.should redirect_to controller: :accounts, action: :favorite
      end

      it "お気に入りが減っていない" do
        lambda{
          post 'delete_favorite', params = {}
        }.should_not change(Favorite,:count).by(-1)
      end
    end

    describe "product_style_idsがあり、ログインしていない場合" do
      it "お気に入り一覧へリダイレクトする" do
        post 'delete_favorite', params = { product_style_ids: [@exists_favorite.product_style_id] }
        response.should redirect_to controller: :accounts, action: :login
      end

      it "お気に入りが減っていない" do
        lambda{
          post 'delete_favorite', params = { product_style_ids: [@exists_favorite.product_style_id] }
        }.should_not change(Favorite,:count).by(-1)
      end
    end

    describe "product_style_idsがあり、ログインしている場合" do
      before do
        session[:customer_id] = @exists_favorite.customer_id
      end

      describe "１つだけ削除" do
        it "お気に入り一覧へリダイレクトする" do
          post 'delete_favorite', params = { product_style_ids: [@exists_favorite.product_style_id] }
          response.should redirect_to controller: :accounts, action: :favorite
        end

        it "お気に入りが減っている" do
          lambda{
            post 'delete_favorite', params = { :product_style_ids => [@exists_favorite.product_style_id] }
          }.should change(Favorite,:count).by(-1)
        end

        it "指定したお気に入り商品が削除されている" do
          post 'delete_favorite', params = { product_style_ids: [@exists_favorite.product_style_id] }
          Favorite.find(:first, :conditions => { :product_style_id => @exists_favorite.product_style_id}).should be_nil
        end
      end

      describe "複数商品を削除" do
        before do
          @exists_favorite2 = favorites(:exists_favorite2)
        end

        it "お気に入り一覧へリダイレクトする" do
          post 'delete_favorite', params = { product_style_ids: [@exists_favorite.product_style_id, @exists_favorite2.product_style_id] }
          response.should redirect_to controller: :accounts, action: :favorite
        end

        it "お気に入りが複数減っている" do
          lambda{
            post 'delete_favorite', params = { product_style_ids: [@exists_favorite.product_style_id, @exists_favorite2.product_style_id] }
          }.should change(Favorite,:count).by(-2)
        end

        it "指定したお気に入り商品が削除されている" do
          post 'delete_favorite', params = { product_style_ids: [@exists_favorite.product_style_id, @exists_favorite2.product_style_id] }
          Favorite.find(:first, :conditions => { :product_style_id => @exists_favorite.product_style_id}).should be_nil
          Favorite.find(:first, :conditions => { :product_style_id => @exists_favorite2.product_style_id}).should be_nil
        end
      end
    end
  end
end
