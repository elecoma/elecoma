class AddResourceUrlToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :resource_url, :string, :comment => "ロゴ画像URL"
    add_column :payments, :without_text, :boolean, :default => false, :comment => "テキスト非表示"
    add_column :payments, :use_remote_resource, :boolean, :default => false, :comment => "リモートの画像使用"
    Payment.find(:all).each do |p|
      execute("UPDATE payments SET without_text = false WHERE id = #{p.id}")
      execute("UPDATE payments SET use_remote_resource = false WHERE id = #{p.id}")
    end
  end

  def self.down
    remove_column :payments, :resource_url
    remove_column :payments, :without_text
    remove_column :payments, :use_remote_resource
  end
end
