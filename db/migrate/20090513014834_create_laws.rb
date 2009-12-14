class CreateLaws < ActiveRecord::Migration
  def self.up
    create_table :laws do |t|
      t.column :company,            :string, :comment => '販売業者'
      t.column :manager,            :string, :comment => '運営責任者'
      t.column :zipcode01,          :string, :comment => '郵便番号（前半）'
      t.column :zipcode02,          :string, :comment => '郵便番号（後半）'
      t.column :prefecture_id,      :integer, :comment => '都道府県ID'
      t.column :address_city,       :string, :comment => '住所（市区町村）'
      t.column :address_detail,     :string, :comment => '住所（詳細）'
      t.column :tel01,              :string, :comment => '電話番号1'
      t.column :tel02,              :string, :comment => '電話番号2'
      t.column :tel03,              :string, :comment => '電話番号3'
      t.column :fax01,              :string, :comment => 'FAX番号1'
      t.column :fax02,              :string, :comment => 'FAX番号2'
      t.column :fax03,              :string, :comment => 'FAX番号3'
      t.column :email,              :string,    :comment => 'メールアドレス'
      t.column :url,                :string,    :comment => 'URL'
      t.column :necessary_charge,   :text,      :comment => '商品代金以外の必要料金'
      t.column :order_method,       :text,      :comment => '注文方法'
      t.column :payment_method,     :text,      :comment => '支払方法'
      t.column :payment_time_limit, :text,      :comment => '支払期限'
      t.column :delivery_time,      :text,      :comment => '引き渡し時期'
      t.column :return_exchange,    :text,      :comment => '返品・交換について'
      t.column :created_at,         :datetime,  :comment => '作成日'
      t.column :updated_at,         :datetime,  :comment => '更新日'
      t.column :deleted_at,         :datetime,  :comment => '削除日'
    end
    add_index :laws, :deleted_at
  end

  def self.down
    remove_index :laws, :deleted_at
    drop_table :laws
  end
end
