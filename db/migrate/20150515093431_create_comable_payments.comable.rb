# This migration comes from comable (originally 20150511171940)
class CreateComablePayments < ActiveRecord::Migration
  def change
    create_table :comable_payments do |t|
      t.references :order, null: false
      t.references :payment_method, null: false
      t.integer :fee, null: false
      t.string :state, null: false
      t.datetime :completed_at
    end
  end
end
