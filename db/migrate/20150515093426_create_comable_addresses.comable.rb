# This migration comes from comable (originally 20141024025526)
class CreateComableAddresses < ActiveRecord::Migration
  def change
    create_table :comable_addresses do |t|
      t.references :user
      t.string :family_name, null: false
      t.string :first_name, null: false
      t.string :zip_code, null: false, limit: 8
      t.references :state
      t.string :state_name, null: false
      t.string :city, null: false
      t.string :detail
      t.string :phone_number, null: false, limit: 18
      t.datetime :last_used_at
    end
  end
end
