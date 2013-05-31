# -*- coding: utf-8 -*-
# Ruby 1.9 + tmail-1.2.7 環境での
#「Encoding::CompatibilityError (incompatible encoding regexp match (ASCII-8BIT regexp with ISO-2022-JP string))」
# エラー対策。
# Rails の場合 config/initializers 以下に配置する。
#

module TMailRuby19Patch
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def force_encoding_for(*syms)
      syms.each do |sym|
        define_method "#{sym}_with_force_encoding" do |string,*args|
          original_encoding = string.encoding
          string.force_encoding(Encoding::ASCII_8BIT)
          result = self.send("#{sym}_without_force_encoding", string, *args)
          result.force_encoding(original_encoding) if result.is_a?(String) && result.encoding == Encoding::ASCII_8BIT
          result
        end

        self.send :alias_method_chain, sym, :force_encoding
      end
    end
  end
end

module TMail
  class Encoder
    include TMailRuby19Patch
    force_encoding_for :phrase
  end

  # Subject欄向けのパッチ
  class Unquoter
    class << self
      include TMailRuby19Patch
      force_encoding_for :unquote_and_convert_to
    end
  end

  # Subject欄向けのパッチ
  class Decoder
    # NKF.nkf の返り値をASCII_8BITに強制変換するようオーバライド
    # 理由: decode メソッドの内部で NKF.nkf の返り値(ISO-2022-JP)と
    #       第一引数(force_encoding_forでASCII_8BITに強制変換した文字列)を結合する処理があり、
    #       例外エラー「incompatible character encodings: ASCII-8BIT and ISO-2022-JP」が発生するため
    module NKF
      extend ::NKF
      class << self
        alias nkf_org nkf
        def nkf(option, string)
          result = self.send(:nkf_org, option, string)
          result.force_encoding(Encoding::ASCII_8BIT) if string.encoding == Encoding::ASCII_8BIT
          result
        end
      end
    end

    class << self
      include TMailRuby19Patch
      force_encoding_for :decode
    end
  end
end
 
class StringOutput
  include TMailRuby19Patch
  force_encoding_for :<<
end

# From欄向けのパッチ
module ActionMailer
  module Quoting
    include TMailRuby19Patch
    force_encoding_for :quote_address_if_necessary
  end
end
