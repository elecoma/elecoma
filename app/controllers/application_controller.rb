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


  def load_system
    @system = System.find(:first)
  end

  #郵便番号から住所を取得
  def get_address
    address = Zip.find(:first, :select => "prefecture_name, address_city, address_details, prefecture_id",
                       :conditions => ["zipcode01=? and zipcode02=?", params[:first], params[:second]])
    data = address[:prefecture_name] + '/' + address[:address_city] + '/' + address[:address_details] + '/' + address[:prefecture_id].to_s
    render :text => data
  end

end

