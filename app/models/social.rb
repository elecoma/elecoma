# -*- coding: utf-8 -*-
class Social < ActiveRecord::Base

  belongs_to :shop

  validates_format_of :mixi_key,
                      :with => /^[a-zA-Z0-9]*$/,
                      :message => "は正しい形式ではありません。"
  validates_length_of :mixi_key, :allow_blank => true, :maximum => 60

  validates_length_of :twitter_user, :allow_blank => true, :maximum => 15

  def validate
    if (mixi_check || mixi_like) && (mixi_description.blank? || mixi_key.blank?)
      errors.add "", "mixi チェック、mixi イイネ！では説明文及びmixi チェックキーの両方が必要です"
    end
  end

end
