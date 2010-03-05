# -*- coding: utf-8 -*-
class Constant < ActiveRecord::Base

  acts_as_paranoid

  ## キー
  # ソフトバンクメールアドレスのドメイン
  DOMAIN_SOFTBANK = 1
  # 開発環境でのURL
  SITE_URL_DEVELOP = 2
  # 移動理由@在庫管理
  MOVEMENT_REASON = 5

  def self.list key
    find(:all, :conditions => ['const_key=?', key], :order => 'position')
  end

  # options_for_select で使う
  def self.list_for_options key
    list(key).map do | record |
      [record.value, record.value]
    end
  end
end
