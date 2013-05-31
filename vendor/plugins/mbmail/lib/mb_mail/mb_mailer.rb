module MbMail
  # http://www.kbmj.com/~shinya/rails_seminar/slides/#(33)
  # JapaneseMailer 実装より
  class MbMailer < ActionMailer::Base

    Dir[File.join(File.dirname(__FILE__), '../tmail/**/*.rb')].sort.each { |f| require f }

    private

    def initialize_defaults_with_charset(*args)
      charset 'iso-2022-jp'
      initialize_defaults_without_charset(*args)
    end

    alias_method_chain :initialize_defaults, :charset

    def create_mail_with_encode_body
      @body = NKF.nkf("-Wj", @body) if @parts.empty?
      create_mail_without_encode_body
    end

    alias_method_chain :create_mail, :encode_body

    public
    # ヘッダに日本語を含める場合に用いる base64 カプセリング
    # http://wiki.fdiary.net/rails/?ActionMailer
    def base64(text, charset="iso-2022-jp", convert=true)
      if convert
        if charset == "iso-2022-jp"
          text = NKF.nkf('-j -m0', text)
        end
      end
      text = [text].pack('m').delete("\r\n")
      "=?#{charset}?B?#{text}?="
    end
  end
end
