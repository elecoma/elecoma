class SubProduct < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :product
  belongs_to :medium_resource,
             :class_name => "ImageResource",
             :foreign_key => "medium_resource_id",
             :dependent => :delete
  belongs_to :large_resource,
             :class_name => "ImageResource",
             :foreign_key => "large_resource_id",
             :dependent => :delete
  validates_length_of :name , :maximum => 100, :allow_blank => true
  validates_length_of :description , :maximum => 100, :allow_blank => true
  alias :medium_resource_old= :medium_resource=
  alias :large_resource_old= :large_resource=
  [:medium_resource, :large_resource].each do  | method_name|
    define_method("#{method_name}=") do | value |
      if value.class == ActionController::UploadedTempfile || value.class == Tempfile
        resource = ImageResource.new_file(value, value.original_filename)
        self.send "#{method_name}_old=".intern, resource
      elsif value.class == ImageResource
        self.send "#{method_name}_old=".intern, value
      else
        nil
      end
    end
  end
end
