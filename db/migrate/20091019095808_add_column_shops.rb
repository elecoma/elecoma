# -*- coding: utf-8 -*-
class AddColumnShops < ActiveRecord::Migration
  def self.up
    add_column :shops, :point_granted_rate, :integer, :comment => "ポイント付与率"
    add_column :shops, :point_at_admission, :integer, :comment => "入会時ポイント"
  end

  def self.down
    remove_columns :shops, :point_granted_rate
    remove_columns :shops, :point_at_admission
  end
end
