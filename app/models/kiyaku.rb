class Kiyaku < ActiveRecord::Base

  acts_as_paranoid
  acts_as_list
  
  validates_presence_of :name,:content
  validates_length_of :name, :maximum => 250, :allow_blank => true
  validates_length_of :content, :maximum => 2000, :allow_blank => true
end
