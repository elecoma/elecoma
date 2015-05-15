# This migration comes from comable (originally 20150111031229)
class CreateComableProductsCategories < ActiveRecord::Migration
  def change
    create_table :comable_products_categories do |t|
      t.references :product, null: false, index: true
      t.references :category, null: false, index: true
    end
  end
end
