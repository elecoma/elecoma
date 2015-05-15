# This migration comes from comable (originally 20150112173706)
class CreateComableImages < ActiveRecord::Migration
  def change
    create_table :comable_images do |t|
      t.references :product, null: false, index: true
      t.string :file, null: false
    end
  end
end
