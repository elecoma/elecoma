# This migration comes from comable (originally 20150423095210)
class CreateComableShipments < ActiveRecord::Migration
  def change
    create_table :comable_shipments do |t|
      t.references :order, null: false
      t.references :shipment_method, null: false
      t.integer :fee, null: false
      t.string :state, null: false
      t.string :tracking_number
      t.datetime :completed_at
    end
  end
end
