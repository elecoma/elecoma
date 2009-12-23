class Category < ActiveRecord::Base
  acts_as_paranoid
  acts_as_list
  acts_as_tree
  has_many :products
  belongs_to :resource,
             :class_name => "ImageResource",
             :foreign_key => "resource_id"
  belongs_to :menu_resource,
             :class_name => "ImageResource",
             :foreign_key => "menu_resource_id"

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

  def parent
    Category.find_by_id(self.parent_id)
  end

  def product_count
    count_num = 0
    get_child_categories.each do | child_category |
      conditions = Product.default_condition
      conditions << ["category_id = ?",  child_category.id]
      count_num +=  Product.count(:conditions => flatten_conditions(conditions))
    end
    return count_num
  end

  def get_child_categories
    get_child_category_ids.map{|child_id| Category.find(child_id)}
  end

  def get_child_category_ids
    if children_ids.nil?
      self.children_ids = get_childs(true).join(",")
      self.save
    end

    children_ids.split(",").map{|child_id| child_id.to_i }
  end

  def self.find_as_nested_array
    return find_as_nested_array_intenal(nil, Category.all(:order => 'position'))
  end

  def get_childs(ids_flg = false)
    if self.children.blank?
      return [return_model_or_id(self, ids_flg)]
    else
      return_childs = [return_model_or_id(self, ids_flg)]
      children.each do | child |
        child.get_child_categories.each do | child_s_child |
          return_childs << return_model_or_id(child_s_child, ids_flg)
        end
      end
      return return_childs
    end
  end

  def position_up
    condition = self.parent_id ? ["parent_id = ?", self.parent_id.to_i] : ["parent_id is null"]
    max_position = Category.maximum(:position, :conditions => condition)
    self.position = max_position ? max_position+1 : 1
  end

  def self.re_position(parent_id)
    condition = parent_id ? ["parent_id = ?", parent_id] : ["parent_id is null"]
    records = Category.find(:all, :conditions=>condition, :order => "position asc")
    records.each_with_index do |record, idx|
      record.update_attribute(:position, idx+1)
    end
  end

  def move_higher
    position_move(true)
  end

  def move_lower
    position_move(false)
  end

  protected

  def position_move(posit)
    condition = self.parent_id ? [["parent_id = ?", self.parent_id.to_i]] : [["parent_id is null"]]
    if posit
      condition << ["position < ?", self.position]
    else
      condition << ["position > ?", self.position]
    end
    next_record = Category.find(:first, :conditions => flatten_conditions(condition), :order => "position asc")
    next_position = next_record.position
    current_position = self.position
    next_record.update_attribute(:position, current_position)
    self.update_attribute(:position, next_position)
  end

  def self.get_list(parent_id)
    if parent_id
      return Category.find(:all, :conditions => ["parent_id = ?", parent_id], :order => "position asc")
    else
      return Category.find(:all, :conditions => ["parent_id is null"], :order => "position asc")
    end
  end

  private
  def return_model_or_id(model, id_flg)
    id_flg ? model.id : model
  end

  def self.find_as_nested_array_intenal(id, all)
    categories = all.select{|c| c.parent_id == id}
    categories.inject([]) do |array, category|
      array << category
      children = find_as_nested_array_intenal(category.id, all)
      array << children unless children.empty?
      array
    end
  end

end
