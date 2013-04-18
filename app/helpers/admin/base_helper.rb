module Admin::BaseHelper
  def date_hyphen(date)
    date && date.strftime("%Y-%m-%d")
  end

  def calendar_date_select(object,method,option= {},js_option= {})
    
    tag = date_select object,method,option

    tag = <<-EOS
      #{date_select object,method,option}
      #{image_tag("../images/calendar/icon_calendar.gif",:id => method)}
      <script type="text/javascript">
      SelectCalendar.createOnLoaded({
      yearSelect: '#{object}_#{method}_1i',
      monthSelect: '#{object}_#{method}_2i',
      daySelect: '#{object}_#{method}_3i'},
     {triggers: ['#{method}'],
      lang: 'ja',
      showEffect: 'SlideDown', 
      hideEffect: 'SlideUp',
      startYear: #{option[:start_year]},
      endYear: #{option[:end_year]}
    EOS

    js_option.each do |(key,value)|
      tag << ',' + key.to_s + ": #{value}"
    end

    tag << '});</script>'

    return tag
  end
end
