class CreateOrderDeliveries < ActiveRecord::Migration
  def self.up
    create_table :order_deliveries do |t|
      t.column :order_id, :integer, :comment => '注文ID'
      t.column :message, :text, :comment => 'その他お問い合わせ'
      t.column :family_name, :string, :comment => '姓'
      t.column :first_name, :string, :comment => '名'
      t.column :family_name_kana, :string, :comment => '姓（カナ）'
      t.column :first_name_kana, :string, :comment => '名（カナ）'
      t.column :email, :string, :comment => '受注時のメールアドレス'
      t.column :tel01, :string, :comment => '電話番号1'
      t.column :tel02, :string, :comment => '電話番号2'
      t.column :tel03, :string, :comment => '電話番号3'
      t.column :fax01, :string, :comment => 'FAX1'
      t.column :fax02, :string, :comment => 'FAX2'
      t.column :fax03, :string, :comment => 'FAX3'
      t.column :zipcode01, :string, :comment => '郵便番号（前半）'
      t.column :zipcode02, :string, :comment => '郵便番号（後半）'
      t.column :prefecture_id, :integer, :comment => '都道府県ID'
      t.column :address_city, :string, :comment => '住所（市区町村）'
      t.column :address_detail, :string, :comment => '住所（詳細）'
      t.column :sex, :integer, :comment => '性別'
      t.column :birthday, :date, :comment => '生年月日'
      t.column :deliv_family_name, :string, :comment => '配送先姓'
      t.column :deliv_first_name, :string, :comment => '配送先名'
      t.column :deliv_family_name_kana, :string, :comment => '配送先姓（カナ）'
      t.column :deliv_first_name_kana, :string, :comment => '配送先名（カナ）'
      t.column :deliv_tel01, :string, :comment => '配送先電話番号1'
      t.column :deliv_tel02, :string, :comment => '配送先電話番号2'
      t.column :deliv_tel03, :string, :comment => '配送先電話番号3'
      t.column :deliv_fax01, :string, :comment => '配送先FAX1'
      t.column :deliv_fax02, :string, :comment => '配送先FAX2'
      t.column :deliv_fax03, :string, :comment => '配送先FAX3'
      t.column :deliv_zipcode01, :string, :comment => '配送先郵便番号（前半）'
      t.column :deliv_zipcode02, :string, :comment => '配送先郵便番号（後半）'
      t.column :deliv_pref_id, :integer, :comment => '配送先都道府県ID'
      t.column :deliv_address_city, :string, :comment => '配送先住所（市区町村）'
      t.column :deliv_address_detail, :string, :comment => '配送先住所（詳細）'
      t.column :subtotal, :integer, :comment => '小計'
      t.column :discount, :integer, :comment => '値引き'
      t.column :deliv_fee, :integer, :comment => '送料'
      t.column :charge, :integer, :comment => '手数料'
      t.column :use_point, :integer, :comment => '使用ポイント'
      t.column :add_point, :integer, :comment => '加算ポイント'
      t.column :total, :integer, :comment => '合計'
      t.column :payment_total, :integer, :comment => 'お支払い合計'
      t.column :delivery_trader_id, :integer, :comment => '配達業者ID'
      t.column :delivery_time_id, :integer, :comment => '配送時間ID'
      t.column :note, :text, :comment => 'SHOPメモ'
      t.column :status, :integer, :comment => 'ステータス'
      t.column :commit_date, :datetime, :comment => '発送済みステータスに変更した日'
      t.column :cell01, :string, :comment => '携帯電話番号1'
      t.column :cell02, :string, :comment => '携帯電話番号2'
      t.column :cell03, :string, :comment => '携帯電話番号3'
      t.column :payment_id, :integer, :comment => '支払方法ID'
      t.column :occupation_id, :integer, :comment => '職業ID'
      t.column :address_select, :integer, :comment => '配送先選択'
      t.column :settlement_id, :integer, :comment => '決済ID'
      t.column :shipped_at, :datetime, :comment => '発送日'
      t.column :delivery_completed_at, :datetime, :comment => '発送完了日'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :order_deliveries, :deleted_at
    add_index :order_deliveries, :deliv_pref_id
    add_index :order_deliveries, :delivery_time_id
    add_index :order_deliveries, :delivery_trader_id
    add_index :order_deliveries, :occupation_id
    add_index :order_deliveries, :order_id
    add_index :order_deliveries, :payment_id
    add_index :order_deliveries, :prefecture_id
  end

  def self.down
    remove_index :order_deliveries, :delivery_time_id
    remove_index :order_deliveries, :delivery_trader_id
    remove_index :order_deliveries, :occupation_id
    remove_index :order_deliveries, :order_id
    remove_index :order_deliveries, :payment_id
    remove_index :order_deliveries, :prefecture_id
    remove_index :order_deliveries, :deliv_pref_id
    remove_index :order_deliveries, :deleted_at
    drop_table :order_deliveries
  end
end
