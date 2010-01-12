class ImageResourceController < BaseController

  #caches_page :show
  def show
    if params[:filename] 
      @res = ImageResource.find_by_name(params[:filename])
    end
    if params[:id]
      @res ||= ImageResource.find_by_id(params[:id])
    end
    raise ActiveRecord::RecordNotFound unless @res
    if request.mobile?
      if params[:width].present? || params[:height].present?
        width, height = [params[:width].to_i, params[:height].to_i]
      else
        width, height = request.mobile.display.width, request.mobile.display.height
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
end
