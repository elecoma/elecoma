# This migration comes from comable (originally 20140817194104)
class CreateComablePaymentMethods < ActiveRecord::Migration
  def change
    create_table :comable_payment_methods do |t|
      t.string :name, null: false
      t.string :payment_provider_type, null: false
      t.integer :payment_provider_kind, null: false
      t.integer :fee, null: false
      t.integer :enable_price_from
      t.integer :enable_price_to
    end
  end
end
