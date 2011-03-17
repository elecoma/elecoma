# -*- coding: utf-8 -*-
class Mail < ActiveRecord::Base
  THRESHOLD = 5
  def self.post_all_mail
    mails = Mail.find(:all, :conditions=>'sent_at is null', :order=>'created_at')
    mails = mails.each do |m|
      customer = Customer.find_by_email_and_activate(m.to_address, Customer::TOUROKU)
      customer && customer.reachable
    end
    settings = ActionMailer::Base.smtp_settings
    logger.info('Mail.post_all_mail: smtp server %s:%d' % [settings[:address], settings[:port]])
    Net::SMTP.start(settings[:address], settings[:port]) do |smtp|
      mails.each do |mail|
        begin
          logger.info('Mail.post_all_mail: send %s -> %s' % [mail.from_address, mail.to_address])
          mail.update_attribute(:sent_at, Time.now)
          smtp.send_message(Base64.decode64(mail.message), mail.from_address, mail.to_address)
        rescue Net::SMTPSyntaxError => e # 5xx
          handle_fatal_error(mail)
        rescue Net::SMTPFatalError => e # 5xx
          handle_fatal_error(mail)
        rescue Net::SMTPServerBusy, Net::SMTPUnknownError => e
          handle_temporary_error(mail)
        end
      end
    end
  end

  def self.handle_fatal_error(mail)
    logger.error('Mail.handle_fatal_error') 
    customer = Customer.find_by_email_and_activate(mail.to_address, Customer::TOUROKU)
    customer or return
    customer.reachable = false
    customer.save
  end

  def self.handle_temporary_error(mail)
    logger.error('Mail.handle_temporary_error')
    # 規定回数を超えたら到達不能とみなす。そうでなければ再送。
    customer = Customer.find_by_email_and_activate(mail.to_address, Customer::TOUROKU)
    customer or return
    customer.mail_delivery_count = 1 if customer.mail_delivery_count.nil?
    customer.mail_delivery_count += 1
    if customer.mail_delivery_count >= THRESHOLD
      customer.reachable = false
    else
      newmail = Mail.new({
        :from_address => mail.from_address,
        :to_address => mail.to_address,
        :message => mail.message})
      newmail.save
    end
    customer.save
  end

end
