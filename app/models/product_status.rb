class ProductStatus < ActiveRecord::Base

  acts_as_paranoid
  belongs_to :product
  belongs_to :status
end
