require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ImageResource do
  fixtures :image_resources,:resource_datas
  before(:each) do
    @resource = image_resources(:resource_00001)
  end
  describe "validateチェック" do
    it "データが正しい" do
      @resource.should be_valid
    end  
  end
  
  describe "その他" do
    it "画像ビュー" do
      @resource.view.should == resource_datas(:one).content
    end
    it "画像データ取得" do
      @resource.content_data.should == resource_datas(:one).content      
    end
    it "画像が保存出来る" do
      file = open("#{RAILS_ROOT}/spec/sea1.PNG") 
      content_file = ActionController::UploadedTempfile.new("CGI")
      content_file.print file.read
      content_file.rewind 
      content_file.content_type ='image/png'
      resource = ImageResource.new_file(content_file, "sea1.PNG")
      resource.name.should == "sea1.PNG"
      resource.content_type.should == "image/png"
      resource.view.should == ResourceData.find_by_resource_id(resource.id).content
    end
    it "サイズ変更" do
      @resource.scaled_image(50,50).should_not be_nil
    end
  end
end
