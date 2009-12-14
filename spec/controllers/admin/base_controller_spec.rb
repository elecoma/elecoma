require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::BaseController do
  fixtures :admin_users, :functions, :authorities, :authorities_functions

  it "should use BaseController" do
    controller.should be_an_instance_of(Admin::BaseController)
  end

end



