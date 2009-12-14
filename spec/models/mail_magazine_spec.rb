require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MailMagazine do
  before(:each) do
    @mail_magazine = MailMagazine.new
  end

  it "should be valid" do
    @mail_magazine.should be_valid
  end
end
