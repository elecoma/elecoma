class ImageResourceController < BaseController
  before_filter :set_mobile_spec

  #caches_page :show
  def show
    if params[:filename] 
      @res = ImageResource.find_by_name(params[:filename])
    end
    if params[:id]
      @res ||= ImageResource.find_by_id(params[:id])
    end
    raise ActiveRecord::RecordNotFound unless @res
    if @mobile_spec && @mobile_spec  =~ /^(\d+)x(\d+)$/
      if params[:width].present? || params[:height].present?
        width, height = [params[:width].to_i, params[:height].to_i]
      else
        width, height = [$1.to_i, $2.to_i]
      end
      send_file @res, @res.scaled_image(width, height)
    else
      send_file @res, @res.view
    end
  end

  def thumbnail
  end

  private
  
  def send_file(res, data)
    raise ActiveRecord::RecordNotFound unless res
    raise ActiveRecord::RecordNotFound unless data
    content_type = res.content_type
    if request.mobile?
      content_type.gsub!(/pjpeg/, "jpeg")
    end
    send_data(data, :type => content_type, :disposition => 'inline')
  end

  MOBILE_SPEC = Hash[*File.read("#{RAILS_ROOT}/db/migrate/fixed_data/mobile_specs.txt").split(/\n/).compact.map{|a|a.split(/\t/)[0...2]}.flatten]

  def set_mobile_spec
    begin
      if request.mobile?
        ua = request.user_agent || ''
        @mobile_spec = case request.mobile
                       when Jpmobile::Mobile::Docomo
                         MOBILE_SPEC["i/#{$1}"] if ua =~ %r{^DoCoMo/(?:1.0/|2.0 )(\w+)}
                       when Jpmobile::Mobile::Au
                         MOBILE_SPEC["a/#{$1}"] if ua =~ %r{^(?:KDDI-|UP\.Browser/.*?-)(\w+)}
                       when Jpmobile::Mobile::Softbank
                         MOBILE_SPEC["s/#{$1}"] if ua =~ %r{^((.*?)/(.*?)/[\w-]+)}
                       end
        if @mobile_device
          @mobile_spec = "#{@mobile_device.width}x#{@mobile_device.height}"
        end
        @mobile_spec ||= "240x320" 
      end
    rescue NoMethodError
      # テストのときは user_agent メソッドがない
      if request.mobile?
        @mobile_spec ||= "240x320" if is_mobile?
      end
    end
  end
end
