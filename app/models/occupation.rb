class Occupation < ActiveRecord::Base

  acts_as_paranoid
  has_many :occupations
end
