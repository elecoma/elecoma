# -*- coding: utf-8 -*-
class Zip < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :prefecture

  require 'csv'
  require 'nkf'
  require 'tempfile'

  ISOLATED, PART_ISOLATED, NOT_ISOLATED = 2,1,0

  BASE_DOMAIN = "www.post.japanpost.jp"
  KEN_ALL_PATH = "/zipcode/dl/oogaki/lzh/ken_all.lzh"
  JIGYOSYO_PATH = "/zipcode/dl/jigyosyo/lzh/jigyosyo.lzh"

  class << self
    def import
      self.delete_all
      import_address
      import_office
    end

    def import_address
      remove_address_zip_csv

      puts "Zip.import_address: Download starting..."
      filepath = download_lzh(KEN_ALL_PATH)
      extract_lzh_to_csv(filepath)

      puts "Zip.import_address: Import starting..."
      create_address_zips_from_csv

      remove_address_zip_csv
      remove_file(filepath)
    end

    def import_office
      remove_office_zip_csv

      puts "Zip.import_office: Download starting..."
      filepath = download_lzh(JIGYOSYO_PATH)
      extract_lzh_to_csv(filepath)

      puts "Zip.import_office: Import starting..."
      create_office_zips_from_csv

      remove_office_zip_csv
      remove_file(filepath)
    end

    def find_by_zipcode(first, second, options={})
      find_by_zipcode01_and_zipcode02(first, second, options)
    end

    private

    def download_lzh(filepath)
      tmp_file = Tempfile.new(File.basename filepath)
      tmp_file.binmode
      Net::HTTP.new(BASE_DOMAIN).get(filepath) do |res|
        tmp_file.write res
      end
      tmp_file.close
      tmp_file.path
    end

    # カレントディレクトリに解凍される
    def extract_lzh_to_csv(filepath)
      LhaLib::x(filepath)
    end

    def address_zip_csv_filepath
      File.basename(KEN_ALL_PATH, '.*') + '.csv'
    end

    def office_zip_csv_filepath
      File.basename(JIGYOSYO_PATH, '.*') + '.csv'
    end

    def remove_address_zip_csv
      remove_file(address_zip_csv_filepath)
    end

    def remove_office_zip_csv
      remove_file(office_zip_csv_filepath)
    end

    def create_address_zips_from_csv
      Zip.transaction do
        csv_open(address_zip_csv_filepath) do |row|
          create_address_zip(row)
        end
      end
    end

    def create_office_zips_from_csv
      Zip.transaction do
        csv_open(office_zip_csv_filepath) do |row|
          create_office_zip(row)
        end
      end
    end

    def create_address_zip(record)
      Zip.create!(
        prefecture_id: record[0][0..1].to_i,
        zipcode01: record[2][0..2],
        zipcode02: record[2][3..6],
        prefecture_name: record[6],
        address_city: record[7],
        address_details: record[8]
      )
    end

    def create_office_zip(record)
      Zip.create!(
        prefecture_id: record[0][0..1].to_i,
        zipcode01: record[7][0..2],
        zipcode02: record[7][3..6],
        prefecture_name: record[3],
        address_city: record[4],
        address_details: record[5] + record[6]
      )
    end

    def csv_open(filepath)
      count = count_file_line(filepath)
      open(filepath).each_with_index do |line,index|
        yield CSV.parse_line(NKF.nkf('-w', line))
        print_progress(index, count)
      end
      puts
    end

    def print_progress(value, max)
      print "#{(value.to_f / max.to_f * 100).ceil}%..." if value % (max / 10) == 0
    end

    def count_file_line(filepath)
      File.read(filepath, encoding: 'Shift_JIS:UTF-8').count("\n")
    end

    def remove_file(filepath)
      FileUtils.rm(filepath, force: true)
    end
  end
end
