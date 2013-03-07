# -*- coding: utf-8 -*-
class AddColumnPrivacies < ActiveRecord::Migration
  def self.up
    add_column :privacies, :content_collect_mobile, :text, :comment => "個人情報収集（モバイル）"
    add_column :privacies, :content_privacy, :text, :comment => "個人情報保護方針（PC）"
    add_column :privacies, :content_privacy_mobile, :text, :comment => "個人情報保護方針（モバイル）"
  end

  def self.down
    remove_columns :privacies, :content_collect_mobile
    remove_columns :privacies, :content_privacy
    remove_columns :privacies, :content_privacy_mobile
  end
end
