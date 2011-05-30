require 'spec_helper'


describe ServiceCooperationsTemplate do
  fixtures :service_cooperations
  fixtures :service_cooperations_templates
  fixtures :products

  describe "validate" do
    before do
      @template = ServiceCooperationsTemplate.new
      @template.template_name = "sql_test_template"
      @template.file_type = 0
      @template.encode = 0
      @template.newline_character = 0
    end

    it "正しいファイル" do
      @template.should be_valid
    end
    it "SQLのチェック" do
      @template.sql = "SELECT * FROM *"
      @template.should be_valid
      @template.sql = "DROP *"
      @template.should_not be_valid
    end
  end

  describe "validateのテスト" do
    before do
      @template = service_cooperations_templates(:one)
    end
    it "正しい条件" do
      @template.should be_valid
    end
    it "テンプレート名は必須" do
      @template.template_name = nil
      @template.should_not be_valid
    end
    it "テンプレート名の文字数チェック" do
      @template.template_name = "a"*200
      @template.should be_valid
      @template.template_name = "a"*201
      @template.should_not be_valid
    end
    it "テンプレートの説明の文字数チェック" do
      @template.description = "a"*9999
      @template.should be_valid
      @template.description = "a"*10000
      @template.should_not be_valid
    end
    it "サービスの名称の文字数チェック" do
      @template.service_name = "a"*20
      @template.should be_valid
      @template.service_name = "a"*201
      @template.should_not be_valid
    end
    it "URL取得用文字列の文字数チェック" do
      @template.url_file_name = 'a'*30
      @template.should be_valid
      @template.url_file_name = 'a'*31
      @template.should_not be_valid
    end
    it "URL取得用文字列は英数字" do
      @template.url_file_name = "abcde"
      @template.should be_valid
      @template.url_file_name = "あいうえお"
      @template.should_not be_valid
    end
    it "ファイル形式の範囲外参照チェック" do
      @template.file_type = -1
      @template.should_not be_valid
    end
    it "エンコードタイプの範囲外参照チェック" do
      @template.encode = -1
      @template.should_not be_valid
    end
    it "改行文字の範囲外参照チェック" do
      @template.newline_character = -1
      @template.should_not be_valid
    end
    it "SQL文の文字数チェック" do
      @template.sql = "a"*2000
      @template.should be_valid
    end
    it "アイテムフィールドの文字数チェック" do
      @template.field_items = "a"*300
      @template.should be_valid
    end
  end

  describe "管理画面関係" do
    it "セレクトタグに渡す配列を生成出来るか" do
      service_templates = ServiceCooperationsTemplate.find(:all)
      @select_lists = []
      service_templates.each do |service_template|
        @select_lists << [ service_template.template_name, service_template.id.to_s ]
      end
      ServiceCooperationsTemplate.select_service_cooperations_templates.sort.should == @select_lists.sort
    end
  end

  describe "差し込みのテスト" do
    before do
      @service = service_cooperations(:one)
      @template = service_cooperations_templates(:nils)
    end
    it "テストデータが正しいかチェック" do
      @service.should be_valid
    end
    it "サービス名を挿入" do
      @service.name = nil
      @service.should_not be_valid
    end
    it "サービス名" do
      @template.service_name = "test"
      insert_template(@service,@template)
      @service.should be_valid
    end
    it "advantageSearch用テンプレートの挿入" do
      @template = service_cooperations_templates(:one)
      insert_template(@service,@template)
      @service.should be_valid
    end
    it "差し込んで出力後のファイルチェック処理" do
      @template = service_cooperations_templates(:test)
      insert_template(@service,@template)
      open(File.dirname(__FILE__) + "/../csv/service_cooperations_sample.csv") {|f|
        @service.file_generate.should eql(NKF.nkf('-w8', f.read))
      }
    end
  end
end

def insert_template(serv,temp)
  serv.name = temp.service_name unless temp.service_name.nil?
  serv.url_file_name = temp.url_file_name unless temp.url_file_name.nil?
  serv.file_type = temp.file_type unless temp.file_type.nil?
  serv.encode = temp.encode unless temp.encode.nil?
  serv.newline_character = temp.newline_character unless temp.newline_character.nil?
  serv.sql = temp.sql unless temp.sql.nil?
  serv.field_items = temp.field_items unless temp.field_items.nil?
end
