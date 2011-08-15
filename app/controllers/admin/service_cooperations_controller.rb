# -*- coding: utf-8 -*-
require "json"

class Admin::ServiceCooperationsController < Admin::BaseController
  before_filter :admin_permission_check_service_cooperation

  def index
    @services = ServiceCooperation.all
  end

  def new
    @service_cooperation = ServiceCooperation.new
  end

  def edit
    @service_cooperation = ServiceCooperation.find_by_id(params[:id])
    if @service_cooperation.nil?
      flash[:notice] = '無効なidが渡されました'
      redirect_to :action => "index"
    end
  end

  def get_template_ajax
    template_id = params[:id]
    unless template_id.blank?
      service_template = ServiceCooperationsTemplate.find_by_id(template_id)
      unless service_template.nil?
        name = service_template.service_name
        url_file_name = service_template.url_file_name
        file_type = service_template.file_type
        encode = service_template.encode
        newline_character = service_template.newline_character
        field_items = service_template.field_items
        sql = service_template.sql
        data = {
          'name'              => name,
          'url_file_name'     => url_file_name,
          'file_type'         => file_type,
          'encode'            => encode,
          'newline_character' => newline_character,
          'field_items'       => field_items,
          'sql'               => sql
        }
        json = JSON::pretty_generate(data)
        render :text => json.to_s
      end
    else
      render :text => ""
    end
  end

  def confirm
    @service_cooperation = ServiceCooperation.find_by_id(params[:id]) || ServiceCooperation.new
    @service_cooperation.attributes = params[:service_cooperation]

    unless @service_cooperation.valid?
      if params[:id].blank?
        render :action => "new"
      else
        render :action => "edit"
      end
    end
    return
  end

  def create
    @service_cooperation = ServiceCooperation.new(params[:service_cooperation])
    if @service_cooperation.save
      flash[:notice] = 'サービスは正常に追加されました'
      redirect_to :action => "index"
    else
      flash[:notice] = 'エラーが発生しました'
      render :action => "new"
    end
  end

  def update
    @service_cooperation = ServiceCooperation.find_by_id(params[:id])
    @service_cooperation.attributes = params[:service_cooperation]
    if @service_cooperation.save
      flash[:notice] = 'サービスは正常に更新されました'
      redirect_to :action => "index"
    else
      flash[:notice] = 'エラーが発生しました'
      render :action => "edit"
    end
  end

  def destroy
    service = ServiceCooperation.find_by_id(params[:id])
    if service
      service.destroy
    else
      flash[:notice] = '削除に失敗しました 無効なidです'
    end
    redirect_to :action => "index"
  end
end
