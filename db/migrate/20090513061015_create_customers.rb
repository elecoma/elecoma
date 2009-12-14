class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.column :zipcode01, :string, :comment => "郵便番号(前半)"
      t.column :zipcode02, :string, :comment => "郵便番号(後半)"
      t.column :tel01, :string, :comment => "電話番号1"
      t.column :tel02, :string, :comment => "電話番号2"
      t.column :tel03, :string, :comment => "電話番号3"
      t.column :fax01, :string, :comment => "FAX番号1"
      t.column :fax02, :string, :comment => "FAX番号2"
      t.column :fax03, :string, :comment => "FAX番号3"
      t.column :sex, :integer, :comment => "性別"
      t.column :age, :integer, :comment => "年齢"
      t.column :point, :integer, :comment => "ポイント"
      t.column :occupation_id, :integer, :comment => "職業ID"
      t.column :prefecture_id, :integer, :comment => "都道府県ID"
      t.column :family_name, :string, :comment => "姓"
      t.column :first_name, :string, :comment => "名"
      t.column :family_name_kana, :string, :comment => "姓(カナ)"
      t.column :first_name_kana, :string, :comment => "名(カナ)"
      t.column :email, :string, :comment => "メールアドレス"
      t.column :mobile_serial, :string, :comment => "携帯固有識別ID"
      t.column :activation_key, :string, :comment => "会員登録時のキー"
      t.column :password, :string, :comment => "パスワード"
      t.column :address_city, :string, :comment => "住所(市町村)"
      t.column :address_detail, :string, :comment => "住所(詳細)"
      t.column :login_id, :string, :comment => "ログインID"
      t.column :birthday, :date, :comment => "生年月日"
      t.column :created_at, :datetime, :comment => "作成日"
      t.column :updated_at, :datetime, :comment => "更新日"
      t.column :activate, :integer, :comment => "会員状態"
      t.column :receive_mailmagazine, :integer, :comment => "メールマガジン受信可否"
      t.column :mobile_carrier, :integer, :comment => "携帯電話キャリア"
      t.column :black, :boolean, :comment => "ブラックリストフラグ"
      t.column :deleted_at, :datetime, :comment => "削除日"
      t.column :mobile_type, :string, :comment => "機種ID"
      t.column :user_agent, :string, :comment => "ユーザーエージェント"
      t.column :corporate_name, :string, :comment => "会社名"
      t.column :corporate_name_kana, :string, :comment => "会社名カナ"
      t.column :section_name, :string, :comment => "部署名"
      t.column :section_name_kana, :string, :comment => "部署名カナ"
      t.column :contact_tel01, :string, :comment => "昼間連絡先電話番号1"
      t.column :contact_tel02, :string, :comment => "昼間連絡先電話番号2"
      t.column :contact_tel03, :string, :comment => "昼間連絡先電話番号3"
      t.column :temp_password, :string, :comment => "暫定パスワード"
      t.column :address_building, :string, :comment => "住所(建物)"
      t.column :cookie, :string, :comment => "クッキー"
      t.column :reachable, :boolean, :comment => "登録メール到着可能フラグ"
      t.column :mail_delivery_count, :integer, :comment => "メール送信回数"
    end
    add_index :customers, :deleted_at
    add_index :customers, :email
    add_index :customers, :login_id
    add_index :customers, :occupation_id
    add_index :customers, :password
    add_index :customers, :prefecture_id
  end

  def self.down
    remove_index :customers, :prefecture_id
    remove_index :customers, :password
    remove_index :customers, :occupation_id
    remove_index :customers, :login_id
    remove_index :customers, :email
    remove_index :customers, :deleted_at
    drop_table :customers
  end
end
