# -*- coding: utf-8 -*-
class CreateCampaigns < ActiveRecord::Migration
  def self.up
    create_table :campaigns do |t|
      t.column :name, :string, :comment => 'キャンペーン名'
      t.column :dir_name, :string, :comment => 'ディレクトリ名'
      t.column :opened_at, :datetime, :comment => '公開開始日時'
      t.column :closed_at, :datetime, :comment => '公開終了日時'
      t.column :max_application_number, :integer, :comment => '最大申し込み人数'
      t.column :application_count, :integer, :comment => '申し込み人数'
      t.column :repeat_application, :boolean, :comment => '重複申し込み条件'
      t.column :put_wagon, :boolean, :comment => 'カートに商品を入れる条件'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :open_pc_free_space_1, :text, :comment => 'PC用キャンペーン中フリースペース1'
      t.column :open_pc_free_space_2, :text, :comment => 'PC用キャンペーン中フリースペース2'
      t.column :open_pc_free_space_3, :text, :comment => 'PC用キャンペーン中フリースペース3'
      t.column :open_pc_free_space_4, :text, :comment => 'PC用キャンペーン中フリースペース4'
      t.column :end_pc_free_space_1, :text, :comment => 'PC用キャンペーン終了フリースペース1'
      t.column :end_pc_free_space_2, :text, :comment => 'PC用キャンペーン終了フリースペース2'
      t.column :end_pc_free_space_3, :text, :comment => 'PC用キャンペーン終了フリースペース3'
      t.column :end_pc_free_space_4, :text, :comment => 'PC用キャンペーン終了フリースペース4'
      t.column :open_mobile_free_space_1, :text, :comment => '携帯用キャンペーン中フリースペース1'
      t.column :open_mobile_free_space_2, :text, :comment => '携帯用キャンペーン中フリースペース2'
      t.column :open_mobile_free_space_3, :text, :comment => '携帯用キャンペーン中フリースペース3'
      t.column :end_mobile_free_space_1, :text, :comment => '携帯用キャンペーン終了フリースペース1'
      t.column :end_mobile_free_space_2, :text, :comment => '携帯用キャンペーン終了フリースペース2'
      t.column :end_mobile_free_space_3, :text, :comment => '携帯用キャンペーン終了フリースペース3'
      t.column :product_id, :integer, :comment => '商品ID'
      t.column :deleted_at, :datetime, :comment => '削除日'
      t.column :product_code, :string, :comment => '商品コード'
    end
    add_index :campaigns, :deleted_at
    add_index :campaigns, :product_id
  end

  def self.down
    remove_index :campaigns, :product_id
    remove_index :campaigns, :deleted_at
    drop_table :campaigns
  end
end
