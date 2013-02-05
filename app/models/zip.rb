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

  def self.import
    Zip.delete_all
    import_address
    import_office
  end

  def self.import_address
    puts "download start "
    FileUtils.rm("ken_all.csv", :force => true)
	http = Net::HTTP.new(BASE_DOMAIN)
    lzhfile = Tempfile.new("ken_all.lzh")
	lzhfile.binmode
    http.get(KEN_ALL_PATH) do |res|
      lzhfile.write res
    end
    lzhfile.close
    require 'lhalib'
    LhaLib::x(lzhfile.path)
    cnt = 0
    rawfile = open("ken_all.csv")
    while rawfile.gets(nil)
      cnt = $_.count("\n")
    end
    #system "rm -f ken_all.lzh; wget -O - http://www.post.japanpost.jp/zipcode/dl/oogaki/lzh/ken_all.lzh | lha x -"
    #cnt = `wc -l ken_all.csv  | awk '{print $1}' `
    Zip.transaction do
      puts "import start "
      zip_file=open("ken_all.csv")

      zip_file.each_with_index do | line,idx |
        line = CSV.parse_line(NKF.nkf("-w",line))
        Zip.new(:prefecture_id => line[0][0..1].to_i,
                :zipcode01 => line[2][0..2],
                :zipcode02 => line[2][3..6],
                :prefecture_name => line[6],
                :address_city => line[7],
                :address_details => line[8]).save!
        # 進行状況を出力（すべてだと負荷が高くなるので一部を出力）
        puts "#{idx+1}/#{cnt}" if (idx % 1000) == 0 || idx+1 == cnt
        STDOUT.flush
      end
    end
    FileUtils.rm("ken_all.csv", :force => true)
    FileUtils.rm(lzhfile.path, :force => true)
    #system("rm ken_all.csv")
  end

  def self.import_office
    puts "download start "
    FileUtils.rm("jigyosyo.csv", :force => true)
	http = Net::HTTP.new(BASE_DOMAIN)
    lzhfile = Tempfile.new("jigyosyo.lzh")
	lzhfile.binmode
    http.get(JIGYOSYO_PATH) do |res|
      lzhfile.write res
    end
    lzhfile.close
    require 'lhalib'
    LhaLib::x(lzhfile.path)
    cnt = 0
    rawfile = open("jigyosyo.csv")
    while rawfile.gets(nil)
      cnt = $_.count("\n")
    end
    #system "rm -f jigyosyo.csv; wget -O - http://www.post.japanpost.jp/zipcode/dl/jigyosyo/lzh/jigyosyo.lzh | lha x -"
    #cnt = `wc -l jigyosyo.csv  | awk '{print $1}' `
    Zip.transaction do
      puts "import start "
      zip_file=open("jigyosyo.csv")

      zip_file.each_with_index do | line,idx |
        line = CSV.parse_line(NKF.nkf("-w",line))
        Zip.new(:prefecture_id => line[0][0..1].to_i,
                :zipcode01 => line[7][0..2],
                :zipcode02 => line[7][3..6],
                :prefecture_name => line[3],
                :address_city => line[4],
                :address_details => line[5]+line[6]).save!
        # 進行状況を出力（すべてだと負荷が高くなるので一部を出力）
        puts "#{idx+1}/#{cnt}" if (idx % 1000) == 0 || idx+1 == cnt
        STDOUT.flush
      end
    end
    FileUtils.rm("jigyosyo.csv", :force => true)
    FileUtils.rm(lzhfile.path, :force => true)
    #system("rm jigyosyo.csv")
  end

  def self.find_by_zipcode(first, second, options={})
    find_by_zipcode01_and_zipcode02(first, second, options)
  end
end
