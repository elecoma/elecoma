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
        define_method "#{sym}_with_force_encoding" do |text,*args|
          enc = text.encoding
          text.force_encoding(Encoding::ASCII_8BIT)
          result = self.send "#{sym}_without_force_encoding", text, *args
          text.force_encoding(enc)
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
    class << self
      include TMailRuby19Patch
      force_encoding_for :decode
    end
  end
end
 
class StringOutput#:nodoc:
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
