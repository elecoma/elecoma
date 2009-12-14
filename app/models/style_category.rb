class StyleCategory < ActiveRecord::Base

  acts_as_paranoid
  acts_as_list
  belongs_to :style

  validates_presence_of :name
  validates_presence_of :style_id

  def has_product?
    ProductStyle.exists?([<<-SQL, {:id=>self.id}])
      style_category_id1=:id or style_category_id2=:id
    SQL
  end

end
