class AddColumnGoogleAnalyticsToSystems < ActiveRecord::Migration
  def self.up
    add_column :systems, :googleanalytics_use_flag, :boolean,:default => false, :comment => "GoogleAnalytics利用可否"
    add_column :systems, :googleanalytics_account_num, :string, :limit => 20, :comment =>"UA-XXXX-XXアカウント番号"
  end

  def self.down
    remove_columns :systems, :googleanalytics_use_flag
    remove_columns :systems, :googleanalytics_account_num
  end
end
