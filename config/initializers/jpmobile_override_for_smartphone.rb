# -*- coding: utf-8 -*-
module Jpmobile
  module Filter
    class Sjis < Base
      # to_internalを適用するべきかどうかを返す。
      def apply_incoming?(controller)
        # Vodafone 3G/Softbank(Shift-JISにすると絵文字で不具合が生じる)以外の
        # 携帯電話の場合に適用する。
        # iPhoneも適応する
        mobile = controller.request.mobile
        mobile && !(mobile.instance_of?(Jpmobile::Mobile::Vodafone)||mobile.instance_of?(Jpmobile::Mobile::Softbank)||mobile.instance_of?(Jpmobile::Mobile::Smartphone))
      end
    end
  end
end
