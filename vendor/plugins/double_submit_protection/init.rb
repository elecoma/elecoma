$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'double_submit_protection'


ActionView::Base.class_eval do
  include Hervalicious::DoubleSubmitProtection::View
end


ActionController::Base.class_eval do
  include Hervalicious::DoubleSubmitProtection::Controller
end
