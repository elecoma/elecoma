class AddMailmagazineIdToMail < ActiveRecord::Migration
  def self.up
    add_column :mails, :mailmagazine_id,:integer
  end

  def self.down
    remove_column :mails, :mailmagazine_id
  end
end
