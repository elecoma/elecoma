require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RecommendController do
  fixtures :products
  #Delete these examples and add some real ones
  it "should use RecommendController" do
    controller.should be_an_instance_of(RecommendController)
  end


  describe "GET 'tsv'" do
    it "should be successful" do
      get 'tsv'
      response.should be_success
      response.headers['Content-Type'].should =~ %r(^application/octet-stream)
      response.headers['Content-Disposition'].should =~ %r(^attachment)
    end
  end
end
