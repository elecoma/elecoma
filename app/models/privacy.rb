# -*- coding: utf-8 -*-
class Privacy < ActiveRecord::Base
  CONTENT_COLLECT,CONTENT_COLLECT_MOBILE,CONTENT_PRIVACY,CONTENT_PRIVACY_MOBILE = "content_collect","content_collect_mobile","content_privacy","content_privacy_mobile"
  PRIVACY_NAMES = {
    CONTENT_COLLECT =>"個人情報収集（PC）",
    CONTENT_COLLECT_MOBILE =>"個人情報収集（モバイル）",
    CONTENT_PRIVACY =>"個人情報保護方針（PC）",
    CONTENT_PRIVACY_MOBILE =>"個人情報保護方針（モバイル）"
   }
end
