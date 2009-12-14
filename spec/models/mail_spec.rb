require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Mail do
  before(:each) do
    @mails = Mail.new
  end

  it "should be valid" do
    @mails.should be_valid
  end
end
