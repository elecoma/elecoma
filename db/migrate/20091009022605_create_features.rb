class CreateFeatures < ActiveRecord::Migration
  def self.up
    create_table :features do |t|
      t.column    :name,              :string,  :comment => '特集名'
      t.column    :dir_name,          :string,  :comment => 'ディレクトリ名'
      t.column    :feature_type,      :integer, :comment => '特集タイプ'
      t.column    :image_resource_id, :integer, :comment => 'タイトル画像'
      t.column    :permit,            :boolean, :comment => '公開・非公開'
      t.column    :body,              :text,    :comment => 'フリースペース'
      t.timestamps
      t.timestamp :deleted_at
    end
  end

  def self.down
    drop_table :features
  end
end
