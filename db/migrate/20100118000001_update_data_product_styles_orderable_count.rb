class UpdateDataProductStylesOrderableCount  < ActiveRecord::Migration      
  def self.up
    ProductStyle.update_all("orderable_count = actual_count")
  end

  def self.down
    ProductStyle.update_all("orderable_count = null")
  end
end
