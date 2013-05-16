# -*- coding: utf-8-hfs -*-
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # not leave password and card number for the log
  filter_parameter_logging 'password', 'number'

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # protect_from_forgery # :secret => 'a24b54af4d852bf12a39dde03d4a0189'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  include ActiveRecordHelper
  
  # セッションハイジャック対策を導入
  include CheckSessionSignature

  before_filter :load_system

  include SslRequirement
  ssl_allowed :get_address

  def load_system
    @system = System.find(:first)
    @system_supplier_use_flag = true if @system && @system.supplier_use_flag
  end

  #郵便番号から住所を取得
  def get_address
    address = Zip.find(:first, :select => "prefecture_name, address_city, address_details, prefecture_id",
                       :conditions => ["zipcode01=? and zipcode02=?", params[:first], params[:second]])
    if address
      data = address[:prefecture_name] + '/' + address[:address_city] + '/' + address[:address_details] + '/' + address[:prefecture_id].to_s
      render :text => data
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def send_csv(text, filename)
    send_data(
      text,
      type: "application/octet-stream; name=#{filename}; charset=shift_jis; header=present",
      disposition: 'attachment',
      filename: filename
    )
  end
  private
  #sslの有効無効をuse_sslで決定する
  def ensure_proper_protocol
    # return true unless @system #specでload_systemが通らない問題に対応するため
    #return false
    return true unless @system.use_ssl
    return true if ssl_allowed?
    
    if ssl_required? && !request.ssl?
      redirect_to "https://" + request.host + request.request_uri
      flash.keep
      return false
    elsif request.ssl? && !ssl_required?
      redirect_to "http://" + request.host + request.request_uri
      flash.keep
      return false
    end
  end

    
end

