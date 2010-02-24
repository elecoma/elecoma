class AddColumnGoogleAnalyticsSelectCodeToSystems < ActiveRecord::Migration
  def self.up
    add_column :systems, :googleanalytics_select_code, :integer,:default => 0, :comment => "トラッキングコードの種類選択"
  end

  def self.down
    remove_columns :systems, :googleanalytics_select_code
  end
end
