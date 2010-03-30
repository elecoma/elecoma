class Style < ActiveRecord::Base
  acts_as_paranoid
  acts_as_list :scope => :retailer_id
  has_many :style_categories, :order => 'position'
  has_many :product_styles,
           :class_name => "ProductStyle",
           :foreign_key => "style_id1"
  has_many :product_styles,
           :class_name => "ProductStyle",
           :foreign_key => "style_id2"
  belongs_to :retailer
  validates_uniqueness_of :name, :scope => :retailer_id, :message=>'は、既に使われています。'
  def self.select_options(id = nil, retailer_id = 1) 
    array = "<option value=\"\">選択して下さい</option>"
    find(:all, :conditions => ["retailer_id = ? ", retailer_id], :order => "id").each{|s| 
      if s.style_categories.size > 0
        array += "<option value='#{s.id}'#{ (id &&  id.to_s == s.id.to_s ) ? " selected=\"selected\"" : ""}>#{s.name}</otpion> "  
      end
    }
    return array
  end

  validates_presence_of :name
  validates_presence_of :retailer

  def has_product?
    style_categories.any?(&:has_product?)
  end

end
