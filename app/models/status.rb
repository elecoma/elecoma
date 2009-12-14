class Status < ActiveRecord::Base

  acts_as_paranoid
  belongs_to :products
end
