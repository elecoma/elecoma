# -*- coding: utf-8 -*-

# override vender/plugins/jpmobile/lib/jpmobile/filter.rb
module Jpmobile
  module Filter
    module Emoticon
      class Outer < Base
        include ApplyOnlyForMobile
        def to_external(str, controller, use_webcode=false)
          table = nil
          to_sjis = false
          case controller.request.mobile
          when Jpmobile::Mobile::Docomo
            table = Jpmobile::Emoticon::CONVERSION_TABLE_TO_DOCOMO
            to_sjis = true
          when Jpmobile::Mobile::Au
            table = Jpmobile::Emoticon::CONVERSION_TABLE_TO_AU
            to_sjis = true
          when Jpmobile::Mobile::Jphone
            table = Jpmobile::Emoticon::CONVERSION_TABLE_TO_SOFTBANK
            to_sjis = true
          when Jpmobile::Mobile::Softbank
            table = Jpmobile::Emoticon::CONVERSION_TABLE_TO_SOFTBANK
          end
          Jpmobile::Emoticon::unicodecr_to_external(str, table, to_sjis, use_webcode)
        end
      end
    end
  end
end

# override vender/plugins/jpmobile/lib/jpmobile/emoticon.rb
module Jpmobile
  module Emoticon
    def self.unicodecr_to_external(str, conversion_table=nil, to_sjis=true, use_webcode=true)
      str.gsub(/&#x([0-9a-f]{4});/i) do |match|
        unicode = $1.scanf("%x").first
        if conversion_table
          converted = conversion_table[unicode] # キャリア間変換
        else
          converted = unicode # 変換しない
        end

        # 携帯側エンコーディングに変換する
        case converted
        when Integer
          # 変換先がUnicodeで指定されている。つまり対応する絵文字がある。
          if sjis = UNICODE_TO_SJIS[converted]
            [sjis].pack('n')
          elsif webcode = SOFTBANK_UNICODE_TO_WEBCODE[converted-0x1000]
            if use_webcode
              "\x1b\x24#{webcode}\x0f"
            else
              [converted-0x1000].pack("U")
            end
          else
            # キャリア変換テーブルに指定されていたUnicodeに対応する
            # 携帯側エンコーディングが見つからない(変換テーブルの不備の可能性あり)。
            match
          end
        when String
          # 変換先がUnicodeで指定されている。
          to_sjis ? Kconv::kconv(converted, Kconv::SJIS, Kconv::UTF8) : converted
        when nil
          # 変換先が定義されていない。
          match
        end
      end
    end
  end
end
