class CreateMails < ActiveRecord::Migration
  def self.up
    create_table :mails do |t|
      t.column :from_address, :string,    :comment => '送信元アドレス'
      t.column :to_address,   :string,    :comment => '送信先アドレス'
      t.column :message,      :text,      :comment => '本文'
      t.column :sent_at,      :datetime,  :comment => '送信時刻'
      t.column :created_at,   :datetime,  :comment => '作成日'
      t.column :updated_at,   :datetime,  :comment => '更新日'
      t.column :deleted_at,   :datetime,  :comment => '削除日'
    end
    add_index :mails, :deleted_at
  end

  def self.down
    remove_index :mails, :deleted_at
    drop_table :mails
  end
end
