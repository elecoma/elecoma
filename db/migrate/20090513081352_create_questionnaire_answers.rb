class CreateQuestionnaireAnswers < ActiveRecord::Migration
  def self.up
    create_table :questionnaire_answers do |t|
      t.column :customer_family_name, :string, :comment => '顧客名（姓）'
      t.column :customer_first_name, :string, :comment => '顧客名（名）'
      t.column :customer_family_name_kana, :string, :comment => '顧客名（姓（カナ））'
      t.column :customer_first_name_kana, :string, :comment => '顧客名（名（カナ））'
      t.column :prefecture_name, :string, :comment => '都道府県名'
      t.column :address_city, :string, :comment => '住所（市区町村）'
      t.column :address_details, :string, :comment => '住所（詳細）'
      t.column :email, :string, :comment => 'メールアドレス'
      t.column :customer_id, :integer, :comment => '顧客ID'
      t.column :zipcode02, :string, :comment => '郵便番号（後半）'
      t.column :tel01, :string, :comment => '電話番号１'
      t.column :tel02, :string, :comment => '電話番号２'
      t.column :tel03, :string, :comment => '電話番号３'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :questionnaire_id, :integer, :comment => 'アンケートID'
      t.column :questionnaire_name, :string, :comment => 'アンケート名'
      t.column :zipcode01, :string, :comment => '郵便番号（前半）'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :questionnaire_answers, :customer_id
    add_index :questionnaire_answers, :deleted_at
    add_index :questionnaire_answers, :questionnaire_id
  end

  def self.down
    remove_index :questionnaire_answers, :questionnaire_id
    remove_index :questionnaire_answers, :deleted_at
    remove_index :questionnaire_answers, :customer_id
    drop_table :questionnaire_answers
  end
end
