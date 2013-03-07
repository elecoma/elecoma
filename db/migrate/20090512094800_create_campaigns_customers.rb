# -*- coding: utf-8 -*-
class CreateCampaignsCustomers < ActiveRecord::Migration
  def self.up
    create_table :campaigns_customers, :id => false do |t|
      t.column :campaign_id, :integer, :comment => 'キャンペーンID'
      t.column :customer_id, :integer, :comment => '顧客ID'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
    end
    add_index :campaigns_customers, :campaign_id
    add_index :campaigns_customers, :customer_id
  end

  def self.down
    remove_index :campaigns_customers, :customer_id
    remove_index :campaigns_customers, :campaign_id
    drop_table :campaigns_customers
  end
end
