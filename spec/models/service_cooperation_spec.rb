# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'nkf'
require 'tempfile'
require 'digest/md5'

describe ServiceCooperation do
  fixtures :service_cooperations
  fixtures :products

  describe "validateのテスト" do
    before do
      @service = service_cooperations(:one)
    end
    it "正しい条件" do
      @service.should be_valid
    end
    it "サービスの名称は必須" do
      @service.name = nil
      @service.should_not be_valid
    end
    it "サービス名称の文字数チェック" do
      @service.name = "a"*200
      @service.should be_valid
      @service.name = "a"*201
      @service.should_not be_valid
    end
    it "URL取得用文字列は必須" do
      @service.url_file_name = nil
      @service.should_not be_valid
    end
    it "URL取得用文字列の文字数チェック" do
      @service.url_file_name = 'a'*30
      @service.should be_valid
      @service.url_file_name = 'a'*31
      @service.should_not be_valid
    end
    valid_url_file_name = [
      "abcdefg",
      "1234566",
      "a___aaa___a____",
      "______",
      "AAAAASSASASA",
      "abc_123",
      "_123abc",
      "123abc_"
    ]
    valid_url_file_name.each do |words|
      it "許可ファイル名のテスト:"+words do
        @service.url_file_name = words
        @service.should be_valid
      end
    end
    non_valid_url_file_name = [
      "ｱｲｳｴｵ",
      "あいうえお",
      "漢字",
      "abcあefg",
      "ＺＥＮＫＡＫＵ",
      "あtest",
      "testあ",
      "1+1"
    ]
    non_valid_url_file_name.each do |words|
      it "禁止ファイル名のテスト:"+words do
        @service.url_file_name = words
        @service.should_not be_valid
      end
    end
    it "URL取得用文字列に使えるのは英数字と'_'です" do
      @service.url_file_name = "abc_123"
      @service.should be_valid
      @service.url_file_name = "あいうえお"
      @service.should_not be_valid
    end
    it "ファイル形式の範囲外参照チェック" do
      @service.file_type = -1
      @service.should_not be_valid
    end
    it "エンコードタイプの範囲外参照チェック" do
      @service.encode = -1
      @service.should_not be_valid
    end
    it "改行文字の範囲外参照チェック" do
      @service.newline_character = -1
      @service.should_not be_valid
    end
    it "SQL文は必須" do
      @service.sql = nil
      @service.should_not be_valid
    end
    
    valid_sql_words = [
      "select alterer from anonymouse",
      "select altalter from anonymouse",
      "select alter_id from anonymouse",
      "select alter,delete from anonymouse",
      "select alter,delete,create form anonymouse",
      "select alter,delete,create,drop,analyze,commit,copy,end form anolyze",
      "SELECT actual from non_actual order by id",
      "select test from alterer",
      "select test from tes_alterer",
      "select delete_at from products",
      "SELECT create_at FROM non_actual",
      "SELECT test from non_actual order by id",
      "SELECT name,id FROM products WHERE id > 5 ORDER BY id",
      "select delete,create,alter,end from non_actual where id < 10 order by id",
      "select commit_table,newline_character FROM test",
      "SELECT template_name,service_name,url_file_name,file_type,encode,newline_character,sql,field_items FROM service_cooperations_templates"
    ]

    valid_sql_words.each do |words|
      it "SQL許可コマンドテスト:"+words do
        @service.sql = words
        @service.should be_valid
      end
    end

    non_valid_sql_words = [
      "ALTER INDEX name RENAME TO super_name FROM products",
      "alter index name rename to super_name from products",
      "CREATE TABLE actual",
      "create table actual",
      "CREATE ROLE jonathan LOGIN",
      "create role jonathan login",
      "CREATE UNIQUE INDEX title_idx ON films(title)",
      "create unique index code_idx ON films(code) TABLESPACE indexspace",
      "CREATE superman name SUPREUSER",
      "create superman name superuser",
      "DROP DOMAIN box",
      "drop function sqrt(integer)",
      "DROP ROLE jonathan",
      "DROP TABLE actual",
      "DELETE FROM test",
      "analyze non_actual",
      "ANALYZE non_actual",
      "COMMIT",
      "COMMIT PREPARED 'foober'",
      "END",
      "COPY name FROM products ORDER BY id",
      "copy name from products order by id"
    ]

    non_valid_sql_words.each do |words|
      it "SQL禁止コマンドテスト:"+words do
        @service.sql = words
        @service.should_not be_valid
      end
    end

    it "SQL文は範囲以内" do
      @service.sql = 'a'*2000
      @service.should be_valid
    end
    it "アイテムフィールドは必須" do
      @service.field_items = nil
      @service.should_not be_valid
    end
    it "アイテムフィールドの文字数チェック" do
      @service.field_items = "a"*300
      @service.should be_valid
    end
  end

  describe "管理画面関係" do
    it "select_file_type メソッドのチェック" do
      output = [ ["CSV", 0],["TSV",1] ]
      ServiceCooperation.select_file_type.sort{ |a,b|
        (a[1] <=> b[1])
      }.should eql(output)
    end
    it "select_encode メソッドのチェック" do
      output = [ ["UTF-8", 0],["SHIFT-JIS",1],["EUC",2],["JIS",3] ]
      ServiceCooperation.select_encode.sort{ |a,b|
        (a[1] <=> b[1])
      }.should eql(output)
    end
    it "select_newline_character メソッドのチェック" do
      output = [ ["CR",0], ["LF",1], ["CR+LF",2] ]
      ServiceCooperation.select_newline_character.sort{ |a,b|
        (a[1] <=> b[1])
      }.should eql(output)
    end
  end
  describe "get_filename メソッド" do
    before do
      @service = service_cooperations(:one)
    end
    it "ファイル名取得チェック" do
      @service.url_file_name = "test"
      @service.file_type = 0
      @service.get_filename.should == "test.CSV"
    end
  end
  describe "file_generate　メソッド" do
    before do
      @service = service_cooperations(:one)
    end
    describe "sqlの検証" do
      before do
        @service.field_items = "name,id"
        @service.file_type = 0
        @service.newline_character = 1
        @service.encode = 0
      end
      it "SQLの検証" do
        # 存在しないテーブル名を指定した時
        @service.sql = "SELECT * FROM no_actual"
        @service.file_generate.should be_nil
        # 存在しないカラム
        @service.sql = "SELECT anonymouse FROM admin_users"
        @service.file_generate.should be_nil
        # 間違ったコマンド名
        @service.sql = "SEEEELCT id,name FROM products"
        @service.file_generate.should be_nil
      end
    end

    describe "CSV-TSV" do
      it "CSV形式出力の検証" do
        @service.sql = "SELECT name,id FROM products WHERE id < 3 ORDER BY id"
        @service.field_items = "name,id"
        @service.file_type = 0
        @service.newline_character = 1
        @service.encode = 0
        open(File.dirname(__FILE__) + "/../csv/service_cooperations_sample.csv") { |f|
          @service.file_generate.should eql(NKF.nkf('-w8', f.read))
          f.close
        }
      end
      
      it "CSV出力照合検証" do
        @service.sql = "SELECT name,id FROM products WHERE id < 3 ORDER BY id"
        @service.field_items = "name,id"
        @service.file_type = 0
        @service.newline_character = 1
        @service.encode = 0
  
        Tempfile.open("test") do |temp|
          temp.puts @service.file_generate
          temp.close
          temp.open
          open(File.dirname(__FILE__) + "/../csv/service_cooperations_sample.csv") do |f|
            Digest::MD5.new.update(temp.read).should == (Digest::MD5.new.update(NKF.nkf('-w8',f.read)))
            f.close
          end
          temp.close!
        end
      end

      it "TSV形式出力の検証" do
        @service.sql = "SELECT name,id FROM products WHERE id < 3 ORDER BY id"
        @service.field_items = "name,id"
        @service.file_type = 1
        @service.newline_character = 2
        @service.encode = 1
        Tempfile.open("test") do |temp|
          temp.puts @service.file_generate
          temp.close
          temp.open
          open(File.dirname(__FILE__) + "/../csv/service_cooperations_sample.tsv") do |f|
            Digest::MD5.new.update(temp.read).should == (Digest::MD5.new.update(NKF.nkf('-s',f.read)))
            f.close
          end
          temp.close!
        end
      end
    
      it "EUCに正しく変換できるか" do
        @service.encode = 2
        NKF.guess(@service.file_generate).should eql(NKF::EUC)
      end
      it "UTF-8に正しく変換できるか" do
        @service.encode = 0
        NKF.guess(@service.file_generate).should eql(NKF::UTF8)
      end
      it "Shift-JISに正しく変換できるか" do
        @service.encode = 1
        NKF.guess(@service.file_generate).should eql(NKF::SJIS)
      end

      it "CR+LFの改行コードのテスト" do
        @service.newline_character = 2
        @service.file_generate.should match(/\r\n/)
      end
      it "LFの改行コードテスト" do
        @service.newline_character = 1
        @service.file_generate.should_not match(/\r\n/)
        @service.file_generate.should_not match(/\r/)
        @service.file_generate.should match(/\n/)
      end
      it "CRの改行コードテスト" do
        @service.newline_character = 0
        @service.file_generate.should_not match(/\r\n/)
        @service.file_generate.should match(/\r/)
        @service.file_generate.should_not match(/\n/)
      end
    end
  end
end
