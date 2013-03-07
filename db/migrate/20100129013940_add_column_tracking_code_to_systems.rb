# -*- coding: utf-8 -*-
class AddColumnTrackingCodeToSystems < ActiveRecord::Migration
  def self.up
    add_column :systems, :tracking_code, :text, :comment =>"トラッキングコード"
  end

  def self.down
    remove_columns :systems, :tracking_code
  end
end
