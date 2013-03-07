# -*- coding: utf-8 -*-
class MailMagazineTemplate < ActiveRecord::Base

  acts_as_paranoid

  TEXT, HTML = 1, 2
  FORM_TYPE_NAMES = {TEXT=>"テキスト", HTML=>"HTML"}

  validates_presence_of :form
  validates_presence_of :subject
  validates_presence_of :body

  def get_form_name
    FORM_TYPE_NAMES[self.form]
  end
end
