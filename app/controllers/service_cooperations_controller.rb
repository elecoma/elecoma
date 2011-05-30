class ServiceCooperationsController < ApplicationController
  def export
    text = nil
    filename = nil
    @service = ServiceCooperation.find_by_url_file_name(params[:url_file_name]) if params[:url_file_name]

    if @service # サービスは取得できたか?
      if @service.enable? # サービスのフラグは有効になっているか
        filename = @service.get_filename
        text = @service.file_generate
      end
    end
    unless text.nil?
      headers['Content-Type'] = "application/octet-stream; name=#{filename}"
      headers['Content-Disposition'] = "attachment; filename=#{filename}"
      render :text => text
    else
      render(:file => "public/404.html", :status => "404 NOT FOUND")
    end
  end
end
