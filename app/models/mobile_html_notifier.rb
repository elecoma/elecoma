class MobileHtmlNotifier < ActiveRecord::Base

  def self.create_html_mailmagazine(customer, mail_body, mail_subject, sent_at = Time.now)
    get_shop
    @subject    = "=?iso-2022-jp?B?#{[NKF.nkf('-j -m0', mail_subject)].pack('m').delete("\r\n")}?="
    @to         = customer.email
    @from       = "=?iso-2022-jp?B?#{[NKF.nkf('-j -m0', @shop.name)].pack('m').delete("\r\n")}?= <#{@shop.mail_sender}>"
    @body = mail_body.gsub("{name}", customer.full_name)

    @body = html_unescape(@body)
    html_text = br_to_div(@body)
    html_body = "<HTML><BODY>#{html_text}</BODY></HTML>"
    text_body = ActionView::Base.full_sanitizer.sanitize(br_to_linefeedcode(@body))
    
    # ヘッダーを作成
    @dm = MbMail::DMail.new
    @dm.from_addrs = [TMail::Address.parse(@shop.mail_sender)]
    @dm.from = @from
    @dm.to = @to
    @dm.subject = @subject
    @dm.body = ''
    @dm.content_type = 'multipart/mixed'

    @text_part = MbMail::DMail.new
    @text_part.transfer_encoding = 'Base64'
    @text_part.content_type = 'text/plain; charset="UTF-8"'
    @text_part.body = Base64.encode64(Jpmobile::Emoticon.utf8_to_unicodecr(text_body))

    @html_part = MbMail::DMail.new
    @html_part.transfer_encoding = 'Base64'
    @html_part.content_type = 'text/html; charset="UTF-8"'
    @html_part.body = Base64.encode64(Jpmobile::Emoticon.utf8_to_unicodecr(html_body))

    @alt_part = MbMail::DMail.new
    @alt_part.body = ''
    @alt_part.content_type = 'multipart/alternative'
    @alt_part.parts << @text_part
    @alt_part.parts << @html_part

    @rel_part = MbMail::DMail.new
    @rel_part.body = ''
    @rel_part.content_type = 'multipart/related'
    @rel_part.parts << @alt_part

    @dm.parts << @rel_part

    if @to.to_s =~ /docomo.ne.jp/
      @dm = @dm.to_docomo_format
    elsif @to.to_s =~ /ezweb.ne.jp/
      @dm = @dm.to_au_format 
    elsif @to.to_s =~ /softbank.ne.jp/ || @to.to_s =~ /vodafone.ne.jp/ || @to.to_s =~ /softbank.jp/
      @dm = @dm.to_softbank_format
    end
    return @dm
  end

  private
  def self.get_shop
    @shop = Shop.find(:first)
  end

  def self.html_unescape(s)
    s.to_s.gsub(/&amp;/, "&").gsub(/&quot;/, "\"").gsub(/&gt;/, ">").gsub(/&lt;/, "<")
  end

  def self.br_to_div(str)
    str = br_to_linefeedcode(str)
    result = ""
    str.split("\n").each do |spstr|
      result += "<DIV>#{spstr}</DIV>"
    end
    result
  end

  def self.br_to_linefeedcode(str)
    return str.gsub(/<[^<>]*>/) do |match|
      if match =~ /br|BR/
        "\n"
      else
        match
      end
    end
  end

end
