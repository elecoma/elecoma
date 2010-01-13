require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FeaturesController do
  fixtures :features

  before do
    @controller.class.skip_before_filter :start_transaction
    @controller.class.skip_after_filter :end_transaction
  end
  #Delete this example and add some real ones
  it "should use FeaturesController" do
    controller.should be_an_instance_of(FeaturesController)
  end

  describe "GET 'show'" do
    it "404 error(PC)" do
      get 'show', :dir_name => features(:not_permit).dir_name
      assigns[:feature].should be_blank
      response.should render_template("public/404.html")
    end

    it "404 error(mobile)" do
      request.user_agent = "SoftBank/1.0/940SH/SHJ001/SN000000000000000 Browser/NetFront/3.5 Profile/MIDP-2.0 Configuration/CLDC-1.1"
      get 'show', :dir_name => features(:not_permit).dir_name
      assigns[:feature].should be_blank
      response.should render_template("public/404_mobile.html")
    end

    it "特殊商品を持っている" do
      get 'show', :dir_name => features(:permit).dir_name
      assigns[:feature].should_not be_blank
      assigns[:products].should_not be_nil
      response.should render_template("features/show.html.erb")
    end

    it "特集商品を持っていない" do
      get 'show', :dir_name => features(:free).dir_name
      assigns[:feature].should_not be_blank
      assigns[:products].should be_nil
      response.should render_template("features/show.html.erb")
    end
  end

end
