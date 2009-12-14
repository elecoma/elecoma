class CreateAuthorities < ActiveRecord::Migration
  def self.up
    create_table :authorities do |t|
      t.column :name, :string, :comment => '権限名'
      t.column :position, :integer, :comment => '順番'
      t.column :create_at, :datetime, :comment => '作成日'
      t.column :update_at, :datetime, :comment => '更新日'
    end
  end

  def self.down
    drop_table :authorities
  end
end
