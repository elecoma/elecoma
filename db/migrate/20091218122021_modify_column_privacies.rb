class ModifyColumnPrivacies < ActiveRecord::Migration
  def self.up
    change_column :privacies, :content, :text, :comment => "個人情報収集（PC）"
    rename_column :privacies, :content, :content_collect
  end

  def self.down
    change_column :privacies, :content_collect,:string
    rename_column :privacies, :content_collect,:content
  end
end
