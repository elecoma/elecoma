class ImageResourceController < BaseController

  ssl_allowed :show, :thumbnail
  #caches_page :show
  def show
    if params[:filename] 
      @res = ImageResource.find_by_name(params[:filename])
    end
    if params[:id]
      @res ||= ImageResource.find_by_id(params[:id].to_i)
    end
    raise ActiveRecord::RecordNotFound unless @res
    if request.mobile? && !request.mobile.respond_to?('smartphone?')
      format = nil
      if request.mobile.instance_of?(Jpmobile::Mobile::Docomo)
        format = :gif
      elsif request.mobile.instance_of?(Jpmobile::Mobile::Au)
        format = :gif
      elsif request.mobile.instance_of?(Jpmobile::Mobile::Softbank)
        format = :png
      else
        format = :jpeg
      end
      if params[:width].present? || params[:height].present?
        width, height = [params[:width].to_i, params[:height].to_i]
      else
        width, height = request.mobile.display.width, request.mobile.display.height
      end
      send_file @res, @res.scaled_image(width, height, format), format
    elsif params[:format]
      send_file @res, @res.view_with_format(params[:format])
    else
      send_file @res, @res.view
    end
  end

  def thumbnail
  end

  private
  
  def send_file(res, data, format = nil)
    raise ActiveRecord::RecordNotFound unless res
    raise ActiveRecord::RecordNotFound unless data
    content_type = res.content_type
    if request.mobile?
      content_type.gsub!(/pjpeg/, "jpeg")
    end
    if format
      case format
      when :gif
        content_type = "image/gif"
      when :png
        content_type = "image/png"
      when :jpeg
        content_type = "image/jpeg"
      end
    end
    send_data(data, :type => content_type, :disposition => 'inline')
  end
end
