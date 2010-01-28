class AddDataFunctionsSupplier < ActiveRecord::Migration
  def self.up
    Function.create(:name=>'仕入先マスタ',:code=>'supplier',:position=>1000)
    f = Function.find_by_code('supplier')
    Authority.find(:all).each do |auth|
      execute("insert into authorities_functions values(#{auth.id},#{f.id})")
    end
  end

  def self.down
    f = Function.find_by_code('supplier')
    Authority.find(:all).each do |auth|
      execute("delete from authorities_functions where authority_id = #{auth.id} and function_id = #{f.id}")
    end
    f.delete
  end
end
