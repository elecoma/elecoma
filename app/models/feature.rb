class Feature < ActiveRecord::Base

  acts_as_paranoid
  
  has_many :feature_products, :dependent => :destroy
  has_many :products, :through => :feature_products
  belongs_to :image_resource,
             :class_name => "ImageResource",
             :foreign_key => "image_resource_id"
  validates_presence_of :name,:dir_name,
                        :message => 'を入力してください'
  validates_presence_of :feature_type,:message => 'を選択してください'
  validates_uniqueness_of :dir_name, :message=>'は、重複しています'

  validates_format_of :dir_name, :with=>/^[\x20-\x7e]*$/, :message=>'は半角英数字または記号で入力してください'

  FREE, PRODUCT = 1, 2
  TYPE_LIST = {FREE => "フリー", PRODUCT => "商品一覧"}

  PERMIT_LABEL = {"公開" => true, "非公開" => false }

  def self.permit_select
    PERMIT_LABEL.collect{|key, value| [key, value]}
  end
  
  def permit_label
    unless @permit_labels
      @permit_labels = Hash.new
      PERMIT_LABEL.each { |key, value| @permit_labels[value] = key }
    end
    @permit_labels[self.permit]
  end
  
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

end
