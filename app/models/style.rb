class Style < ActiveRecord::Base
  acts_as_paranoid
  acts_as_list
  has_many :style_categories, :order => 'position'
  has_many :product_styles,
           :class_name => "ProductStyle",
           :foreign_key => "style_id1"
  has_many :product_styles,
           :class_name => "ProductStyle",
           :foreign_key => "style_id2"
  validates_uniqueness_of :name, :message=>'は、既に使われています。'
  def self.select_options(id = nil) 
    array = "<option value=\"\">選択して下さい</option>"
    find(:all).each{|s| 
      if s.style_categories.size > 0
        array += "<option value='#{s.id}'#{ (id &&  id.to_s == s.id.to_s ) ? " selected=\"selected\"" : ""}>#{s.name}</otpion> "  
      end
    }
    return array
  end

  validates_presence_of :name

  def has_product?
    style_categories.any?(&:has_product?)
  end

end
