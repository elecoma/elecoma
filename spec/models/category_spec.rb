require File.dirname(__FILE__) + '/../spec_helper'

describe Category do
  fixtures :categories, :products, :image_resources,:suppliers

  before(:each) do
    @category = categories(:dai_category)
  end

  it "should be valid" do
    @category.should be_valid
  end
  
  it "parent_idと等しいidのレコードを返す" do
    category_id = Category.create
    category_id_parent = Category.create(:parent_id=>category_id.id)
    category_id_parent.parent.should == category_id
  end

  it "商品数を返す" do
    count_before = @category.product_count
    product = products(:valid_product)
    product.small_resource = image_resources(:resource_00001)
    product.medium_resource = image_resources(:resource_00001)
    @category.products.create(product.attributes)
    count_after = @category.product_count
    (count_after-count_before).should == 1
  end

  it "子カテゴリIDを返す(children_idsを保存する)" do
    @category.get_child_category_ids.sort.should == [@category.id, categories(:chu_category).id, categories(:sho_category).id, categories(:chu_category_two).id, categories(:valid_category).id].sort
  end

  it "Categoryをツリー構造にする" do
   Category.find_as_nested_array.should == [@category,[categories(:chu_category),[categories(:sho_category)],categories(:chu_category_two),categories(:valid_category)],categories(:console_update_test_category)]
  end
  
  it "positionのシーケンス" do
    category_new=Category.create(:parent_id => 1)
    category_new.position.should == 4
  end
  
  it "positionを上へ" do
    id = categories(:chu_category).id
    id_position = categories(:chu_category).position
    id_two = categories(:chu_category_two).id
    id_two_position = categories(:chu_category_two).position
    categories(:chu_category_two).move_higher
    Category.find_by_id(id).position.should == id_two_position
    Category.find_by_id(id_two).position.should == id_position
  end

  it "positionを下へ" do
    id = categories(:chu_category).id
    id_position = categories(:chu_category).position
    id_two = categories(:chu_category_two).id
    id_two_position = categories(:chu_category_two).position
    categories(:chu_category).move_lower
    Category.find_by_id(id).position.should == id_two_position
    Category.find_by_id(id_two).position.should == id_position
  end
  
  it "指定したparent_idのオブジェクトを返す" do
    Category.get_list(1).should == [categories(:chu_category),categories(:chu_category_two),categories(:valid_category)]
  end
  #
  #id: 1 position: 1 children_ids: '1,2,3,4,16'
  #id: 2 parent_id: 1 position: 1 children_ids: '2,3'
  #id: 3 parent_id: 2 position: 1 children_ids: '3'
  #id: 4 parent_id: 1 position: 2 children_ids: '4'
  #id: 16 parent_id: 1 position: 3 children_ids: '16'
  #  
  it "create後、親のchildren_idsが自動更新1" do
    children_ids_old = Category.find_by_id(1).children_ids
    Category.create(:parent_id => 1)
    children_ids_new = Category.find_by_id(1).children_ids
    children_ids_new.split(",").size.should == children_ids_old.split(",").size + 1
  end
  it "create後、親のchildren_idsが自動更新2" do
    Category.find_by_id(1).children_ids.split(",").size.should == 5
    Category.create(:parent_id => 3)
    Category.find_by_id(1).children_ids.split(",").size.should == 6
    Category.find_by_id(2).children_ids.split(",").size.should == 3
    Category.find_by_id(3).children_ids.split(",").size.should == 2    
  end
  it "destory後、親のchildren_idsが自動更新1" do
    Category.find_by_id(1).children_ids.split(",").size.should == 5
    c = Category.find_by_id(4)
    c.destroy
    Category.find_by_id(1).children_ids.split(",").size.should == 4
    Category.find_by_id(1).children_ids.split(",").include?("4").should be_false
  end
  it "destory後、親のchildren_idsが自動更新2" do
    Category.find_by_id(1).children_ids.split(",").size.should == 5
    Category.find_by_id(2).children_ids.split(",").size.should == 2
    c = Category.find_by_id(3)
    c.destroy
    Category.find_by_id(1).children_ids.split(",").size.should == 4
    Category.find_by_id(2).children_ids.split(",").size.should == 1
    Category.find_by_id(1).children_ids.split(",").include?("3").should be_false
    Category.find_by_id(2).children_ids.split(",").include?("3").should be_false
  end
  it "destory後、positionが自動更新" do
    Category.find_by_id(16).position.should == 3
    c = Category.find_by_id(4)
    c.destroy
    Category.find_by_id(16).position.should == 2
  end  
  it "consoleからchildren_idsを更新" do
    Category.renew_children_ids_with_command
    Category.find_by_id(17).children_ids.should == "17"
  end
end
