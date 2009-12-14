require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::MailMagazineTemplatesController do
  fixtures :mail_magazine_templates, :admin_users

  before do
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter :admin_permission_check_template
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
      assigns[:mail_magazine_template].id.should be_nil
    end
  end

  describe "GET 'edit'" do
    before do
      @mail_magazine_template = mail_magazine_templates(:valid_success)
    end
    it "should be successful" do
      get 'edit', :id=>@mail_magazine_template.id
      response.should be_success
      assigns[:mail_magazine_template].attributes.should == @mail_magazine_template.attributes
    end

    it "データが取得できない場合" do
      lambda{ get 'edit', :id => MailMagazineTemplate.maximum(:id) + 1 }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET 'preview'" do
    before do
      @mail_magazine_template = mail_magazine_templates(:valid_success)
    end 

    it "should be successful" do
      get 'preview', :id => @mail_magazine_template.id
      response.should be_success
      assigns[:mail_magazine_template].attributes.should == @mail_magazine_template.attributes
    end

    it "データ取得できなかった場合" do
      get 'preview', :id => MailMagazineTemplate.maximum(:id) + 1
      response.should be_success
      assigns[:mail_magazine_template].id.should be_nil
    end
  end

  describe "POST 'update'" do
    before do
      @mail_magazine_template = mail_magazine_templates(:valid_success)
    end
    it "should be successful" do
      @mail_magazine_template.body = "test"
      post 'update', :id => @mail_magazine_template.id, :mail_magazine_template => @mail_magazine_template.attributes
      response.should redirect_to(:action => :index)
      assigns[:mail_magazine_template].body.should == @mail_magazine_template.body
      assigns[:mail_magazine_template].attributes.should == MailMagazineTemplate.find(@mail_magazine_template.id).attributes
    end

    it "保存に失敗した場合" do
      @mail_magazine_template.body = "a" * 100001
      post 'update', :id => @mail_magazine_template.id, :mail_magazine_template => @mail_magazine_template.attributes
      response.should render_template("admin/mail_magazine_templates/edit.html.erb")
      MailMagazineTemplate.find(@mail_magazine_template.id).body.should_not == @mail_magazine_template.body
    end
  end

  describe "POST 'create'" do
    before do
      @mail_magazine_template = MailMagazineTemplate.new(:form => MailMagazineTemplate::TEXT, 
                                                         :subject => "test",
                                                         :body => "test")
    end
    it "should be successful" do
      post 'create', :mail_magazine_template => @mail_magazine_template.attributes
      response.should redirect_to(:action=>:index)
      assigns[:mail_magazine_template].subject.should == @mail_magazine_template.subject
      assigns[:mail_magazine_template].should == MailMagazineTemplate.find(:first, :order=>"id desc")
    end

    it "保存に失敗した場合" do
      count = MailMagazineTemplate.count
      @mail_magazine_template.body = "a"*100001
      post 'create', :mail_magazine_template => @mail_magazine_template.attributes
      response.should render_template("admin/mail_magazine_templates/new.html.erb")
      MailMagazineTemplate.count.should == count
    end
  end
end
