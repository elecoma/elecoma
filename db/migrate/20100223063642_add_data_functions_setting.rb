# -*- coding: utf-8 -*-
class AddDataFunctionsSetting < ActiveRecord::Migration
  def self.up
    Function.create(:name => '環境設定', :code => 'setting', :position => 1003)
    f = Function.find_by_code('setting')
    now = ActiveRecord::Base.connection.quote(Time.now.utc)
    Authority.find(:all).each do |auth|
      execute("INSERT INTO authorities_functions (authority_id, create_at, function_id, update_at) VALUES (#{auth.id}, #{now}, #{f.id}, #{now})")
    end
  end

  def self.down
    f = Function.find_by_code('setting')
    Authority.find(:all).each do |auth|
      AuthoritiesFunction.delete_all(["authority_id = :authority_id and function_id = :function_id", {:authority_id => auth.id, :function_id => f.id}])
    end
    f.delete
  end
end
