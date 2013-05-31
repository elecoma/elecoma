# -*- coding: utf-8 -*-
class Admin::AccountsController < Admin::BaseController
  skip_before_filter :admin_login_check
  layout nil, :only => 'login'

  def login
    if request.request_method == :post
      if params[:admin_user]
        if params[:admin_user][:login_id] == ''
          flash.now[:error] = "ログインIDを入力して下さい。"
          return
        elsif params[:admin_user][:password] == ''
          flash.now[:error] = "パスワードを入力して下さい。"
          return
        end
      else
        flash.now[:error] = "ログインIDを入力してください"
        return
      end
      admin_user = AdminUser.find_by_login_id_and_password(params[:admin_user][:login_id], params[:admin_user][:password])

      if admin_user.nil?
        flash.now[:error] = "ログインIDもしくはパスワードが正しくありません。"
        return
      else
        session[:admin_user] = admin_user
        if session[:return_to_admin]
          # login_check で飛ばされた場合
          redirect_to url_for(session[:return_to_admin])
          session[:return_to_admin] = nil
          return
        else
          # 普通に来た場合
          redirect_to :controller=>"/admin/home", :action=>:index
          return
        end
      end
    end
  end

  def logout
    session[:admin_user] = nil
    session[:return_to_admin] = nil
    redirect_to :controller=>"admin/accounts", :action=>:login
  end

end
