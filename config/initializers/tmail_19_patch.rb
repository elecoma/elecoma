# -*- coding: utf-8 -*-
# Ruby 1.9 + tmail-1.2.7 環境での
#「Encoding::CompatibilityError (incompatible encoding regexp match (ASCII-8BIT regexp with ISO-2022-JP string))」
# エラー対策。
# Rails の場合 config/initializers 以下に配置する。
#

module TMail19Jp
  def self.encoding_handler(text)
    raise unless block_given?
    enc = text.encoding
    text.force_encoding(Encoding::ASCII_8BIT)
    result = yield
    text.force_encoding(enc)
    result
  end
end

module TMail
  class Encoder
    alias :phrase_org :phrase

    def phrase(str)
      TMail19Jp::encoding_handler(str) do
        phrase_org(str)
      end
    end
  end

  # Subject欄向けのパッチ
  class Unquoter
    class << self
      alias :unquote_and_convert_to_org :unquote_and_convert_to

      def unquote_and_convert_to(text, to_charset, from_charset = "iso-8859-1", preserve_underscores=false)
        TMail19Jp::encoding_handler(text) do
          unquote_and_convert_to_org(text, to_charset, from_charset, preserve_underscores)
        end
      end
    end
  end
end
 
class StringOutput#:nodoc:
  alias :push_org :<<

  def <<(str)
    TMail19Jp::encoding_handler(str) do
      push_org(str)
    end
  end
end

# From欄向けのパッチ
module ActionMailer
  module Quoting
    alias :quote_address_if_necessary_org :quote_address_if_necessary

    def quote_address_if_necessary(address, charset)
      TMail19Jp::encoding_handler(address) do
        quote_address_if_necessary_org(address, charset)
      end
    end
  end
end
