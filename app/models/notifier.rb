# -*- coding: utf-8 -*-
#require 'gettext/rails'
GetText.locale = 'ja'

class Notifier < ActionMailer::Base
@@charset='iso-2022-jp'

  def pc_inquiry(inquiry, sent_at = Time.now)
    get_shop
    mail_template = MailTemplate.find_by_name "問い合わせ確認メール"
    @subject    = Kconv.tojis(mail_template.title )
    @recipients = inquiry.email
    @from       = '"%s" <%s>' % [@shop.name, @shop.mail_sender]
    @from       = Kconv.tojis(@from)
    @sent_on    = sent_at
    @headers    = {}
    @body = body :inquiry => inquiry, :mail_template => mail_template
  end

  def mobile_inquiry(inquiry,  sent_at = Time.now)
    get_shop
    mail_template = MailTemplate.find_by_name "問い合わせ確認メール"
    @subject    = Kconv.tojis(mail_template.title )
    @recipients = inquiry.email
    @from       = '"%s" <%s>' % [@shop.name, @shop.mail_sender]
    @from       = Kconv.tojis(@from)
    @sent_on    = sent_at
    @headers    = {}
    @body = body :inquiry => inquiry, :mail_template => mail_template
  end

  def received_inquiry(inquiry, is_mobile, sent_at = Time.now)
    get_shop
    @subject    = Kconv.tojis("No:#{inquiry.id} お問い合わせがありました")
    @recipients = @shop.mail_faq
    @from       = '"%s" <%s>' % [inquiry.name, inquiry.email]
    @from       = Kconv.tojis(@from)
    @sent_on    = sent_at
    @headers    = {}
    @body = body(:inquiry => inquiry, :shop => @shop)
  end

  def reminder(customer, password, sent_at = Time.now)
    get_shop
    mail_template = MailTemplate.find_by_name "パスワード再発行メール"
    @subject    = Kconv.tojis(mail_template.title )
    @recipients = customer.email
    @from       = '"%s" <%s>' % [@shop.name, @shop.mail_sender]
    @from       = Kconv.tojis(@from)
    @sent_on    = sent_at
    @headers    = {'Content-Transfer-Encoding' => '7bit'}
    @body = body :customer => customer, :password => password, :shop => @shop, :mail_template => mail_template
  end

  def mobile_reminder(customer, password, sent_at = Time.now)
    get_shop
    mail_template = MailTemplate.find_by_name "パスワード再発行メール"
    @subject    = Kconv.tojis(mail_template.title )
    @recipients = customer.email
    @from       = '"%s" <%s>' % [@shop.name, @shop.mail_sender]
    @from       = Kconv.tojis(@from)
    @sent_on    = sent_at
    @headers    = {'Content-Transfer-Encoding' => '7bit'}
    @body = body :customer => customer, :password => password, :shop => @shop, :mail_template => mail_template
  end

  def activate(customer, url, sent_at = Time.now)
    get_shop
    mail_template = MailTemplate.find_by_name "会員登録受付メール"
    if customer.mobile_carrier != Customer::NOT_MOBILE
      @template += '_mobile'
    end

    @subject    = Kconv.tojis(mail_template.title )
    @recipients = customer.email
    @from       = '"%s" <%s>' % [@shop.name, @shop.mail_sender]
    @from       = Kconv.tojis(@from)
    @sent_on    = sent_at
    @headers    = {'Content-Transfer-Encoding' => '7bit'}
    @body = body :customer => customer, :url => url, :shop => @shop, :mail_template => mail_template
  end

  def text_mailmagazine(customer, mail_body, mail_subject, sent_at = Time.now)
    get_shop
    @subject    = Kconv.tojis(mail_subject)
    @recipients = customer.email
    @from       = '"%s" <%s>' % [@shop.name, @shop.mail_sender]
    @from       = Kconv.tojis(@from)
    @sent_on    = sent_at
    @headers    = {'Content-Transfer-Encoding' => '7bit'}
    @body = body :mail_body => mail_body.gsub(/\{name\}/, customer.full_name)
  end

  def html_mailmagazine(customer, mail_body, mail_subject, sent_at = Time.now)
    get_shop
    @subject    = Kconv.tojis(mail_subject)
    @recipients = customer.email
    @from       = '"%s" <%s>' % [@shop.name, @shop.mail_sender]
    @from       = Kconv.tojis(@from)
    @sent_on    = sent_at
    @headers    = {'Content-Transfer-Encoding' => '7bit'}
    @body = body :mail_body => mail_body.gsub("{name}", customer.full_name)
    @content_type = "text/html"
  end

  def buying_complete(order)
    get_shop
    order = order
    order_delivery = order.order_deliveries[0]
    order_details = order_delivery.order_details

    if order.customer && order.customer.mobile_carrier != Customer::NOT_MOBILE
      @template += '_mobile'
    end

    mail_template = MailTemplate.find_by_name "注文受付メール"
    @subject    = Kconv.tojis(mail_template.title )
    @recipients = order_delivery.email
    @from       = '"%s" <%s>' % [@shop.name, @shop.mail_sender]
    @from       = Kconv.tojis(@from)
    @sent_on    = Time.now
    @body = body(:order=>order, :order_delivery=>order_delivery, :order_details=>order_details, :shop=>@shop, :mail_template => mail_template)
  end

  private

  def get_shop
    @shop = Shop.find(:first)
  end

  # 本文 (body) を iso-2022-jp へ変換
  def create!(*)
    super
    @mobile_filter = nil
    @docomo_or_au = nil
    docomo_charset = "Shift_JIS"
    au_charset = "'iso-2022-jp'"
    softbank_charset = "UTF-8"
    use_charset = nil
    dummy_controller = DummyController.new
    logger.debug "MAILTO------"
    logger.debug @mail.to
    if @mail.to.to_s =~ /docomo.ne.jp/
      dummy_controller.request.mobile = Jpmobile::Mobile::Docomo.new(dummy_controller.request)
      @mobile_filter = true
      @docomo_or_au = true
      use_charset = docomo_charset
      logger.debug "DOCOMO------"
    elsif @mail.to.to_s =~ /ezweb.ne.jp/
      dummy_controller.request.mobile = Jpmobile::Mobile::Au.new(dummy_controller.request)
      @mobile_filter = true
      @docomo_or_au = true
      use_charset = au_charset
      logger.debug "EZWEB------"
    elsif @mail.to.to_s =~ /softbank.ne.jp/ || @mail.to.to_s =~ /vodafone.ne.jp/ || @mail.to.to_s =~ /softbank.jp/
      dummy_controller.request.mobile = Jpmobile::Mobile::Softbank.new(dummy_controller.request)
      @mobile_filter = true
      use_charset = softbank_charset
      logger.debug "SOFTBANK------"
    end

    # セッション ID を削る
    @mail.body = @mail.body.gsub(/([?&])_ec_session=[a-zA-Z0-9_]+(&?)/) do |m|
      $2.empty? ? '' : $1
    end

    if @mobile_filter
      use_webcode = false
      mail_title = @docomo_or_au ? NKF.nkf("-xWs", @mail.subject) : @mail.subject
      mail_title = Jpmobile::Filter::Emoticon::Outer.new.to_external(mail_title, dummy_controller, use_webcode)
      @mail.subject = @docomo_or_au ? mail_title : (mail_title)
      @mail.body = @docomo_or_au ? NKF.nkf("-xWs", @mail.body) : @mail.body
      @mail.body = Jpmobile::Filter::Emoticon::Outer.new.to_external(@mail.body, dummy_controller, use_webcode)
      @mail.body = @docomo_or_au ? @mail.body : Base64.b64encode(@mail.body)
      if @mail.content_type =~ /.*text\/html.*/
        @mail.set_content_type "text/html; charset=#{use_charset}"
      else
        @mail.set_content_type "text/plain; charset=#{use_charset}"
      end

      @mail.transfer_encoding = "base64" unless @docomo_or_au
    else
      if @mail.content_type =~ /.*text\/html.*/
        @mail.set_content_type "text/html; charset=iso-2022-jp"
      else
        @mail.set_content_type "text/plain; charset=iso-2022-jp"
      end
      @mail.body.gsub(/～/, '〜') # U+55FE(FULLWIDTH TILDE) -> U+301C(WAVE DASH)
      @mail.subject = NKF.nkf('-j', @mail.subject)
      @mail.body = NKF.nkf('-j', @mail.body)
    end
    @mail
  end


  class DummyController
    attr_accessor :request
    def initialize
      self.request = DummyRequest.new
    end

    class DummyRequest
      attr_accessor :mobile
    end
  end
end
