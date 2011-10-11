module Jpmobile::Mobile
  class Smartphone < AbstractMobile
#    autoload :IP_ADDRESSES, 'jpmobile/mobile/z_ip_addresses_softbank'

    #USER_AGENT_REGEXP = /^Mozilla\/5.0 \(iP(hone|od).*AppleWebKit\/.*Mobile\//
    USER_AGENT_REGEXP = /^Mozilla\/5.0 \((iP(hone|od)|.*Android).*AppleWebKit\/.*Mobile.*/
     #USER_AGENT_REGEXP = /(iPhone)/


    def supports_cookie? 
      true
    end 

    def smartphone?
      true
    end
  end
end