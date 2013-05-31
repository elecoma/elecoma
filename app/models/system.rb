# -*- coding: utf-8 -*-
class System < ActiveRecord::Base
  require 'moji'

  acts_as_paranoid
  NON_MEMBERS_ALLOW, NON_MEMBERS_DISALLOW = 0, 1
  BUYING_RULE_NAMES = { NON_MEMBERS_ALLOW => "非会員の購入を許可する", NON_MEMBERS_DISALLOW => "非会員の購入を許可しない" }
  MALE, FEMALE = 1, 2
  SEX_NAMES = { MALE => "男性", FEMALE => "女性" }

  # カタカナに一致する正規表現
  #   Ruby 1.9 で正規表現のライブラリが代わったので
  #   下記の旧コードでは動作しない
  #                  /^(?:\xE3\x82[\xA1-\xBF]|\xE3\x83[\x80-\xB6\xBC])*$/
  KATAKANA_PATTERN = /^(#{Moji.zen_kata}|ー|－)*$/ # 鬼車（\p{katakana}）だと半角カナも含まれるので moji を利用

  #googleanalytics（トラッキングコード）の同期・非同期の区別
  GA_SELECT_SYNCH = 0
  GA_SELECT_ASYNCH = 1
  GA_SELECT_MANUAL = 2

  def validate_on_create
    errors.add "","複数のデータは登録できません。"  if System.count > 0
  end

  def validate
    if self.googleanalytics_use_flag
      if self.googleanalytics_select_code == GA_SELECT_MANUAL
        if self.tracking_code.nil? || self.tracking_code.size == 0
          errors.add(:tracking_code, "を入力してください。")
        end
      end
      if self.googleanalytics_select_code != GA_SELECT_MANUAL
        if self.googleanalytics_account_num.nil? || self.googleanalytics_account_num.size == 0
          errors.add(:googleanalytics_account_num, "を入力してください")
        elsif  self.googleanalytics_account_num =~ /[^A-Za-z0-9-]/
          errors.add(:googleanalytics_account_num, "を正しく入力してください")
        end
      end
    end
  end

  validates_length_of :googleanalytics_account_num, :maximum=>20, :allow_blank=>true, :message=> 'は20文字以内で入力してください。'
  validates_length_of :tracking_code, :maximum=>5000, :allow_blank=>true, :message=> 'は5000文字以内で入力してください。'
end
