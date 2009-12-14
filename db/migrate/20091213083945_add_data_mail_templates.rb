class AddDataMailTemplates < ActiveRecord::Migration
  def self.up
    MailTemplate.delete_all

    directory = File.join(File.dirname(__FILE__), "fixed_data")
    Fixtures.create_fixtures(directory, "mail_templates")
  end

  def self.down
    MailTemplate.delete_all
  end
end
