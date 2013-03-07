# -*- coding: utf-8 -*-
class FeatureProduct < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :feature
  belongs_to :product
  belongs_to :image_resource,
             :class_name => "ImageResource",
             :foreign_key => "image_resource_id"

  validates_presence_of :product_id,:feature_id,
                        :message => "を選択してください"
  
  #前処理
  before_create :position_up

  #画像アップロード
  alias :image_resource_old= :image_resource=
  [:image_resource].each do  | method_name|
    define_method("#{method_name}=") do | value |
      if value.class == ActionController::UploadedStringIO || value.class == ActionController::UploadedTempfile || value.class == Tempfile
        image_resource = ImageResource.new_file(value, value.original_filename)
        self.send "#{method_name}_old=".intern, image_resource
      elsif value.class == ImageResource
        self.send "#{method_name}_old=".intern, value
      else
        nil
      end
    end
  end
  
  protected
  
  def position_up
    if FeatureProduct.maximum(:position) != nil
      self.position = FeatureProduct.maximum(:position) + 1
    else
      self.position = 1
    end
  end
end
