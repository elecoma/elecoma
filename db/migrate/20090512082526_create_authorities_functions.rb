# -*- coding: utf-8 -*-
class CreateAuthoritiesFunctions < ActiveRecord::Migration
  def self.up
    create_table :authorities_functions, :id => false do |t|
      t.column :authority_id, :integer, :comment => '管理者権限ID'
      t.column :function_id, :integer, :comment => '機能ID'
      t.column :create_at, :datetime, :comment => '作成日'
      t.column :update_at, :datetime, :comment => '更新日'
    end
  end

  def self.down
    drop_table :authorities_functions
  end
end
