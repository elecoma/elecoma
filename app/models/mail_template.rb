class MailTemplate < ActiveRecord::Base

  acts_as_paranoid
  
  validates_presence_of :name,:title
  
  validates_length_of :header,:footer, :maximum => 3000, :allow_blank => true
end
