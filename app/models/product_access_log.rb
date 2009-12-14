require 'net/http'
require 'timeout'

class ProductAccessLog < ActiveRecord::Base
  def self.send_bcon
    product_access_logs = ProductAccessLog.find(:all, :conditions => ["send_flg = ? or send_flg is null", false])
    product_access_logs && product_access_logs.each do | product_access_log |
      begin
        next if product_access_log.send_flg
        timeout(1) {
          Net::HTTP.version_1_2
          Net::HTTP.start('recommend.kbmj.com', 80) {|http|
            k = product_access_log.complete_flg ?  "view_dummy_id" : "buy_dummy_id" #TODO:閲覧・購入履歴用のビーコンIDを設定して下さい
            uid = ""
            if product_access_log.docomo_flg 
              uid = product_access_log.customer_id.blank? ? product_access_log.session_id : product_access_log.customer_id
            else
              uid = product_access_log.ident.blank? ? product_access_log.session_id : product_access_log.ident
            end
            url ="/bcon/#{product_access_log.complete_flg ? "heavier" : "basic"}/?k=#{k}&id[]=#{product_access_log.product_id}&uid=#{uid}"
            req = Net::HTTP::Get.new(url)
            req['referer'] = "SITE_URL" #TODO:サイトURLを入れてください
            response = http.request(req)
            logger.info "send_bcon url:#{ url } / response #{ response.code } "
          }
          product_access_log.send_flg = true
          product_access_log.save!
        }
    rescue TimeoutError => e
      p "err: #{ e }"
      logger.info "err: #{ e }"
      return false
    rescue 
      rescue
      end
    end
  end
end
