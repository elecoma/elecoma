# -*- coding: utf-8 -*-
class CreateSocials < ActiveRecord::Migration
  def self.up
    create_table :socials do |t|
      t.column :shop_id, :integer, :comment => "ショップID"
      t.column :google, :boolean, :default => false, :comment => "Google+1"
      t.column :twitter, :boolean, :default => false, :comment => "Twitter"
      t.column :twitter_user, :string, :comment => "Twitter User"
      t.column :facebook, :boolean, :default => false, :comment => "Facebook"
      t.column :gree, :boolean, :default => false, :comment => "gree"
      t.column :evernote, :boolean, :default => false, :comment => "Evernote"
      t.column :hatena, :boolean, :default => false, :comment => "はてなブックマーク"
      t.column :mixi_check, :boolean, :default => false, :comment => "mixi Check"
      t.column :mixi_like, :boolean, :default => false, :comment => "mixi Like"
      t.column :mixi_description, :string, :comment => "mixi 説明文"
      t.column :mixi_key, :string, :comment => "mixi チェックキー"
      t.timestamps
    end
  end

  def self.down
    drop_table :socials
  end
end
