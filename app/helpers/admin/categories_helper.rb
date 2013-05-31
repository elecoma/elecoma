# -*- coding: utf-8 -*-
module Admin::CategoriesHelper
  def set_category_list
    id = params[:category_id] || 0
    return_str = ""
    Category.find(:all, :conditions => ["parent_id is null"], :order => "position" ).each do |category| 
      return_str += make_category_list(category, id)
    end
    return return_str
  end

  def make_category_list(category, id, depth = 0)
    return_str = "　" * depth
    if id.to_s == category.id.to_s  || depth > 3
      return_str += category.name  
    else
      return_str +=link_to(category.name,{:category_id => category.id, :id => nil})
    end
    return_str += "<br>"

    if category.get_child_category_ids.include?(id.to_i) 
      if get_categories = Category.find(:all, :conditions => ["parent_id = ?", category.id], :order => "position") 
        if ! get_categories.empty?
          get_categories.each do |get_category|
              return_str += make_category_list get_category, id, depth + 1
          end
        end
      end
    end
    return return_str 
  end
end
