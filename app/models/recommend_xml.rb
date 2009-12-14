class RecommendXml < ActiveRecord::Base

  belongs_to :recommend, :class_name => 'Product'
  belongs_to :product

end
