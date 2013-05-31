# -*- coding: utf-8 -*-
class AddColumnDesigns < ActiveRecord::Migration
  def self.up
    add_column :designs, :mobile_header, :text, :comment => "MBヘッダー"
    add_column :designs, :mobile_footer, :text, :comment => "MBフッター"
  end

  def self.down
    remove_columns :designs, :mobile_header
    remove_columns :designs, :mobile_footer
  end
end
