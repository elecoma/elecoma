# -*- coding: utf-8 -*-
require 'ostruct'
require 'totalizer'

class Admin::TotalsController < Admin::BaseController
  before_filter :admin_permission_check_term

  def index
    
    #searchに商品集計用の要素を追加
    params[:search] ||= {}
    [:month, :date_from, :date_to, :sale_start_from, :sale_start_to].each do | key |
      params[:search][key] = parse_date_select(params[:search], key)
    end
   
    #販売元id=ログインしているユーザーの販売元id 
    params[:search][:retailer_id] ||= session[:admin_user].retailer_id
   
    #ログインユーザーのショップが無くて販売元idが違ったらエラー 
    if !session[:admin_user].master_shop? && params[:search][:retailer_id] != session[:admin_user].retailer_id
      raise ActiveRecord::RecordNotFound
    end
    
    #OpenStructのsearch生成
    @search = OpenStruct.new(params[:search])

    #:pageがnilだったら代入
    params[:page] ||= 'term'

    #:pageのクラス取得
    @agent = Totalizer.get_instance(params[:page])
    
    #取得できなかったら取得
    if not @agent
      params[:page] = 'term'
      @agent = Totalizer.get_instance(params[:page])
    end
    
    #productのページだったらtrue
    @sale_start_enabled = (params[:page] == 'product')
    params[:type] ||= @agent.default_type
    
    #
    @title = @agent.title
    @list_view = @agent.columns
    @links = @agent.links
    @labels = @agent.labels
    
    #当てはまったものをレコードに入れる
    begin
      @records = @agent.get_records(params)
    rescue => e
      logger.error e.message
      e.backtrace.each{|bt|logger.error(bt)}
    end

    @total = @agent.total
    
    #
    begin
      flash[:graph] = @agent.graph
    rescue =>e
      logger.error(e.message)
      e.backtrace.each{|bt|logger.error(bt)}
    end
    
    #
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
    params[:search][:retailer_id] ||= session[:admin_user].retailer_id
    totalizer = Object.const_get("#{params[:page]}_totalizer".classify)
    csv_data, filename = totalizer.csv(params)
    send_data(csv_data.tosjis, :type => "application/octet-stream; name=#{filename}; charset=shift_jis; header=present",:disposition => 'attachment', :filename => filename)
  end
end

