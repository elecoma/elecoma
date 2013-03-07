# -*- coding: utf-8 -*-
# 顧客管理で検索条件を格納するフォーム
class MailMagazineSearchForm < SearchForm
  validates_numericality_of :customer_id, :only_integer => true, :allow_blank => true, :message => 'は半角数字のみを入力してください。'
  validates_format_of :customer_name_kana, :with => System::KATAKANA_PATTERN, :allow_blank => true, :message => 'は全角カタカナを入力してください。'
  validates_format_of :email, :with => /[\x1-\x7f]/, :allow_blank => true, :message => 'は半角英数字のみを入力してください。'
  validates_numericality_of :tel_no, :only_integer => true, :allow_blank => true, :message => 'は半角数字のみを入力してください。'
  validates_numericality_of :total_from, :only_integer => true, :allow_blank => true, :message => 'は半角数字のみを入力してください。'
  validates_numericality_of :total_to, :only_integer => true, :allow_blank => true, :message => 'は半角数字のみを入力してください。'
  validates_numericality_of :order_count_from, :only_integer => true, :allow_blank => true, :message => 'は半角数字のみを入力してください。'
  validates_numericality_of :order_count_to, :only_integer => true, :allow_blank => true, :message => 'は半角数字のみを入力してください。'
end
