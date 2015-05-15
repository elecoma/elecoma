# This migration comes from comable (originally 20140926063541)
class CreateComableStores < ActiveRecord::Migration
  def change
    create_table :comable_stores do |t|
      t.string :name
      t.string :meta_keywords
      t.string :meta_description
      t.string :email_sender
      t.boolean :email_activate_flag, null: false, default: true
    end
  end
end
