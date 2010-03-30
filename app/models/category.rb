class Category < ActiveRecord::Base
  acts_as_paranoid
  acts_as_list :scope => :parent_id
  acts_as_tree :order => "position"
  has_many :products
  belongs_to :resource,
             :class_name => "ImageResource",
             :foreign_key => "resource_id"
  belongs_to :menu_resource,
             :class_name => "ImageResource",
             :foreign_key => "menu_resource_id"
  
  after_create  :after_process
  before_destroy :destroy_before_process
  after_destroy :after_process
  
  alias :resource_old= :resource=
  alias :menu_resource_old= :menu_resource=
  [:resource, :menu_resource].each do  | method_name|
    define_method("#{method_name}=") do | value |
      if value.class == ActionController::UploadedStringIO || value.class == ActionController::UploadedTempfile || value.class == Tempfile
        image_resource = ImageResource.new_file(value, value.original_filename)
        self.send "#{method_name}_old=".intern, image_resource
      elsif value.class == ImageResource
        self.send "#{method_name}_old=".intern, value
      else
        nil
      end
    end
  end

  def product_count
    count_num = 0
    get_child_category_ids.each do | child_category_id |      
      conditions = Product.default_condition
      conditions << ["category_id = ?",  child_category_id]
      count_num +=  Product.count(:conditions => flatten_conditions(conditions))
    end
    return count_num
  end

  def get_child_category_ids
    children_ids.split(",").map{|child_id| child_id.to_i }
  end

  def self.find_as_nested_array
    return find_as_nested_array_intenal(nil, Category.all(:order => 'position'))
  end

  def destroy_before_process
    self.update_attribute(:children_ids,nil)
  end
  #後処理（create/destroy共通）
  def after_process
    renew_children_ids(self)
  end
  
  protected
  def self.get_list(parent_id)
    if parent_id
      return Category.find(:all, :conditions => ["parent_id = ?", parent_id], :order => "position asc")
    else
      return Category.find(:all, :conditions => ["parent_id is null"], :order => "position asc")
    end
  end

  private
  def self.find_as_nested_array_intenal(id, all)
    categories = all.select{|c| c.parent_id == id}
    categories.inject([]) do |array, category|
      array << category
      children = find_as_nested_array_intenal(category.id, all)
      array << children unless children.empty?
      array
    end
  end
  #自分関連の一連親のみ更新
  #   Example:
  #   root
  #    \_ child1
  #         \_ subchild1
  #         \_ subchild2
  #   subchild1.ancestors # => [child1, root]
  def renew_children_ids(category)
    #destroyの場合、category.frozen?->true
    #createの場合、category.frozen?->false
    #createの時、children_ids=nilなので、ここでまず更新自分自身を更新
    unless category.frozen?
      category.update_attribute(:children_ids,category.id.to_s)
    end
    #一連の親を更新
    p_categories = category.ancestors
    unless p_categories.blank?
      p_categories.each do |p_c|
        new_children_ids = get_new_children_ids(p_c).join(",")
        p_c.update_attribute(:children_ids,new_children_ids)
      end
    end
  end
  def get_new_children_ids(category)
    return_childs = [category.id]
    c_categories = category.children
    unless c_categories.blank?
      c_categories.each do | child |
        child.children_ids.split(",").each do | c_child_id |
          return_childs << c_child_id.to_i
        end
      end
    end
    return_childs
  end

#ここからはコンソールからカテゴリ全テーブルのchildren_idsを更新する時の後処理の関連メソッド
  #1.エントリー
  def self.renew_children_ids_with_command
    begin
      logger.info "batch update start..."
      Category.transaction {
        #clear all
        Category.clear_children_ids
        
        p_categories = Category.find(:all, :conditions => ["parent_id is null"], :order => "position asc" )
        #親カテゴリre_postion
        Category.re_position(nil)
        #親カテゴリをグループとして更新
        p_categories.each do |category| 
          #children_idsを更新
          Category.re_save_childs_id(category)
          #positionを更新
          Category.childs_re_position(category)
        end
      }
      logger.info "batch update end..."
    rescue
      logger.info "batch update error.rollback..."
    end

  end
  #1-1.clear all
  def self.clear_children_ids
    Category.update_all("children_ids = null")
  end
  #1-2.children_ids再生成
  def self.re_save_childs_id(category)
    category.children_ids = Category.get_childs_id(category).join(",")
    category.save
  end
  #1-2-1.children_idsを取得
  def self.get_childs_id(category)
    return_childs = [category.id]
    c_categories = category.children
    unless c_categories.blank?
      c_categories.each do | child |
        Category.re_save_childs_id(child)
        child.children_ids.split(",").each do | c_child_id |
          return_childs << c_child_id.to_i
        end
      end
    end
    return_childs
  end
  #1-3.子カテゴリpositionを更新
  def self.childs_re_position(category)
    c_categories = category.children
    unless c_categories.blank?
      #子カテゴリpositionを更新
      Category.re_position(category.id)
      c_categories.each do |c_category|
        #孫カテゴリpositionを更新
        Category.childs_re_position(c_category)
      end
    end
  end
  def self.re_position(parent_id)
    condition = parent_id ? ["parent_id = ?", parent_id] : ["parent_id is null"]
    records = Category.find(:all, :conditions=>condition, :order => "position asc")
    records.each_with_index do |record, idx|
      record.update_attribute(:position, idx+1)
    end
  end
#ここまではコンソールからカテゴリ全テーブルのchildren_idsを更新する時の後処理の関連メソッド  
end
