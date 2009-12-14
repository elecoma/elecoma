class CreateAdminUsers < ActiveRecord::Migration
  def self.up
    create_table :admin_users do |t|
      t.column :name, :string, :comment => 'ログイン名'
      t.column :belongs_to, :string, :comment => '所属'
      t.column :login_id, :string, :comment => 'ログインID'
      t.column :password, :string, :comment => 'パスワード'
      t.column :authority_id, :integer, :comment => '管理者権限ID'
      t.column :activity, :integer, :comment => '可動/非稼働'
      t.column :position, :integer, :comment => '順番'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :admin_users, :deleted_at
    add_index :admin_users, :login_id
    add_index :admin_users, :position
  end

  def self.down
    remove_index :admin_users, :position
    remove_index :admin_users, :login_id
    remove_index :admin_users, :deleted_at
    drop_table :admin_users
  end
end
