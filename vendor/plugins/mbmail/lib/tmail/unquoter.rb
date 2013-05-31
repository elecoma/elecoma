require 'nkf'
# convert_to で機種依存文字や絵文字に対応するために
# Unquoter 内で NKF を使用するようにしたもの
module TMail
  class Unquoter
    class << self
      # http://www.kbmj.com/~shinya/rails_seminar/slides/#(30)
      def convert_to_with_nkf(text, to, from)
        if text && to =~ /^utf-8$/i && from =~ /^iso-2022-jp$/i
          NKF.nkf("-Jw", text)
        elsif text && from =~ /^utf-8$/i && to =~ /^iso-2022-jp$/i
          NKF.nkf("-Wj", text)
        else
          convert_to_without_nkf(text, to, from)
        end
      end

      alias_method_chain :convert_to, :nkf
    end
  end
end
