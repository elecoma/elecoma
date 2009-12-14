class CreateSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.column :session_id, :string, :comment => 'セッションID'
      t.column :data, :text, :comment => 'セッション情報'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
    end
    add_index :sessions, :session_id
    add_index :sessions, :updated_at
  end

  def self.down
    remove_index :sessions, :updated_at
    remove_index :sessions, :session_id
    drop_table :sessions
  end
end
