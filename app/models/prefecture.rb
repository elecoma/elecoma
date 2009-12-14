class Prefecture < ActiveRecord::Base

  acts_as_paranoid
  has_many :zips
end
