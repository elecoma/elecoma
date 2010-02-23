# -*- coding: utf-8-emacs -*-
class AddDataFunctionsSetting < ActiveRecord::Migration
  def self.up
    Function.create(:name => '環境設定', :code => 'setting', :position => 1003)
    f = Function.find_by_code('setting')
    Authority.find(:all).each do |auth|
      execute("insert into authorities_functions values(#{auth.id},#{f.id})")
    end
  end

  def self.down
    f = Function.find_by_code('setting')
    Authority.find(:all).each do |auth|
      execute("delete from authorities_functions where authority_id = #{auth.id} and function_id = #{f.id}")
    end
    f.delete
  end
end
