# -*- coding: utf-8 -*-
class MailMagazineContentsForm < SearchForm
  set_field_names :subject => '件名'
  set_field_names :body => '本文'

  validates_presence_of :subject
  validates_presence_of :body
  validates_length_of :subject, :maximum => 256
  validates_length_of :body, :maximum => 5120
end
