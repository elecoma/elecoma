require File.dirname(__FILE__) + '/../spec_helper'

describe Category do
  fixtures :categories, :products, :image_resources

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

  it "子カテゴリを返す" do
    @category.get_child_categories.sort{|a, b| a.id <=> b.id}.should == [@category, categories(:chu_category), categories(:sho_category), categories(:chu_category_two), categories(:valid_category)].sort{|a, b| a.id <=> b.id}
  end

  it "子カテゴリIDを返す(children_idsを保存する)" do
    @category.get_child_category_ids.sort.should == [@category.id, categories(:chu_category).id, categories(:sho_category).id, categories(:chu_category_two).id, categories(:valid_category).id].sort
    category_new = Category.create()
    category_new.children_ids.should == nil
    category_new.get_child_category_ids
    category_new.children_ids.should == category_new.id.to_s
  end

  it "子カテゴリを返す(引数がtrueのときIDを返す)" do
    category_new = Category.create()
    category_new.get_childs().should == [category_new]
    category_new.get_childs(true).should == [category_new.id]
    @category.get_childs.sort{|a, b| a.id <=> b.id}.should == [@category, categories(:chu_category), categories(:sho_category), categories(:chu_category_two), categories(:valid_category)].sort{|a, b| a.id <=> b.id}
    @category.get_childs(true).sort.should == [@category.id, categories(:chu_category).id, categories(:sho_category).id, categories(:chu_category_two).id, categories(:valid_category).id].sort
  end
  
	it "Categoryをツリー構造にする" do
   Category.find_as_nested_array.should == [@category,[categories(:chu_category),[categories(:sho_category)],categories(:chu_category_two),categories(:valid_category)]]
  end
  
  it "positionのシーケンス" do
    category_new=Category.create(:parent_id => 1)
    max_position=Category.maximum(:position, :conditions => {:parent_id=>1})
    category_new.position_up.should==max_position+1
  end
  
  it "positionを１から順に並べ直す" do
    category_new = Category.create(:parent_id => 1)
    Category.delete(4)
    Category.re_position(1)
    Category.find_by_id(2).position.should == 1
    Category.find_by_id(category_new.id).position.should == 3
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
end
