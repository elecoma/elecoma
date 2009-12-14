module Admin::BaseHelper
  def date_hyphen(date)
    date && date.strftime("%Y-%m-%d")
  end


end
