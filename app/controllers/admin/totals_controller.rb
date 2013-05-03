# -*- coding: utf-8 -*-
require 'ostruct'
require 'totalizer'

class Admin::TotalsController < Admin::BaseController
  before_filter :admin_permission_check_term

  def index

    params[:search] ||= {}
    [:month, :date_from, :date_to, :sale_start_from, :sale_start_to].each do | key |
      params[:search][key] = parse_date_select(params[:search], key)
    end
    params[:search][:retailer_id] ||= session[:admin_user].retailer_id
    if !session[:admin_user].master_shop? && params[:search][:retailer_id] != session[:admin_user].retailer_id
      raise ActiveRecord::RecordNotFound
    end
    @search = OpenStruct.new(params[:search])
    params[:page] ||= 'term'
    @agent = Totalizer.get_instance(params[:page])
    if not @agent
      params[:page] = 'term'
      @agent = Totalizer.get_instance(params[:page])
    end
    @sale_start_enabled = (params[:page] == 'product')
    params[:type] ||= @agent.default_type
    @title = @agent.title
    @list_view = @agent.columns
    @links = @agent.links
    @labels = @agent.labels
    begin
      @records = @agent.get_records(params)
    rescue => e
      logger.error e.message
      e.backtrace.each{|bt|logger.error(bt)}
    end
    @total = @agent.total
    begin
      flash[:graph] = @agent.graph
    rescue =>e
      logger.error(e.message)
      e.backtrace.each{|bt|logger.error(bt)}
    end
    @selected_retailer = params[:search][:retailer_id].to_i
  end

  def graph
    if flash[:graph]
      send_data flash[:graph], :type => 'image/png', :disposition => 'inline'
    else
      head :status => :not_found
    end
  end

  def csv
    totalizer = Object.const_get("#{params[:page]}_totalizer".classify)
    csv_data, filename = totalizer.csv(params)
    send_data(csv_data, :type => "application/octet-stream; name=#{filename}; charset=shift_jis; header=present",:disposition => 'attachment', :filename => filename)
  end
end

