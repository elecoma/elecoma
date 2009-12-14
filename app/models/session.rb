class Session < ActiveRecord::Base

  def self.cleanup_session(num = 60)
    Session.delete_all(["updated_at < ?", num.minute.ago] )
  end
end
