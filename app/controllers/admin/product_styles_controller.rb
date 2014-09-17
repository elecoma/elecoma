# -*- coding: utf-8 -*-
class Admin::ProductStylesController < Admin::BaseController
  before_filter :admin_permission_check_product,
    :only => [:create, :new]

  
  def new
    @product = Product.find_by_id(params[:id].to_i)

	if @product.is_set 
		redirect_to :controller => 'products', :action => 'index'
		flash.now[:error] = "セット商品には規格を登録できません"
	end

    set_product_styles(params[:id].to_i)
    set_style_category
  end

  def create_form
    @product = Product.find_by_id(params[:id].to_i)
    set_style_category
    if @style1.nil? && ! @style2.nil?
      @error_message = "規格1が無い状態で規格 2を登録出来ません。"
    end
    if @style1 && @style1 == @style2
      @error_message = "規格１、規格２で同一規格の選択はできません"
    end
    render :layout => false
  end


  def confirm
    set_product_styles
    set_style_category
    unless @save_flg
      render :action => "new"
    end
  end

  def create
    set_product_styles
    if @save_flg
      @product.product_styles = @product_styles if @product.product_styles.empty?
      @product.have_product_style = true
      @product.save

      # has_manyが正常に動かない時の対策
      @product_styles.each do |ps|
        ps.save
      end

      #product_styles新規生成時に単品の商品ならproduct_order_unitも作成する
	  unless @product.is_set?
      	@ps = @product.product_styles.first
	  	 unless ProductOrderUnit.exists?(:product_style_id => @ps.id)
      		#product_styles新規生成時に単品の商品ならproduct_order_unitも作成する
      		@pou = ProductOrderUnit.new
      		@pou.set_flag = false 
      	    @pou.product_style_id = @ps.id
      	    @pou.sell_price = @ps.sell_price
            @pou.save
       	 end
	  end
      flash.now[:notice] = "保存しました"
    else
      flash.now[:error] = "保存に失敗しました"
    end
    redirect_to :controller => "products", :action => "index"
  end

  #在庫管理履歴プレビュー
  def stock_histories
    product_style_id = params[:id].to_i
    if !product_style_id.blank? && product_style_id.to_s =~ /^\d*$/
      @product_style = ProductStyle.find_by_id(product_style_id.to_i)
      if !@product_style.blank?
        @stock_histories = @product_style.stock_histories
      end
    else
      raise "Parameter Invalid"
    end
  end
  
  protected

  def set_style_category
    @product_product_styles ||= []
    if params[:style_id1]
      @style1 = Style.find_by_id(params[:style_id1].to_i) unless params[:style_id1].blank?
      @style2 = Style.find_by_id(params[:style_id2].to_i) unless params[:style_id2].blank?
      if @product_product_styles.blank?
        @product.product_styles.each do | p_s |
          @product_product_styles << p_s
        end
      end
    else
      unless @product.product_styles.empty?
        @product.product_styles.each do | p_s |
          @product_product_styles << p_s
        end
        #p @product_product_sytles
        @style1 = @product.product_styles.first.style_category1 && @product.product_styles.first.style_category1.style
        @style2 = @product.product_styles.first.style_category2 && @product.product_styles.first.style_category2.style
      end
    end
    @style_category1 = @style1.style_categories if @style1
    @style_category2 = @style2.style_categories if @style2
    @style_category1 ||= [nil]
    @style_category2 ||= [nil]

    @product_style_flg = false
    @product_styles = {}
    @product_product_styles.each do |p_s|
      @product_style_flg = true
      @product_styles["#{p_s.style_category_id1}_#{p_s.style_category_id2}"] = p_s
      logger.debug "#{p_s.style_category_id1}_#{p_s.style_category_id2}"
    end
  end

  def set_product_styles(id = params[:product_id].to_i)
    @product = Product.find_by_id(id)
    if params[:product_styles]
      @product_styles = []
      @save_flg = true
      params[:product_styles].each do |idx, value|
        if value[:enable] == "on"
          unless product_style = ProductStyle.find(:first,
                                                   :conditions => ["style_category_id1 #{value[:style_category1].blank? ? "is" : "=" } :style_category_id1 and style_category_id2 #{value[:style_category2].blank? ? "is" : "=" } :style_category_id2 and product_id = :product_id",
                                                     {:style_category_id1 => value[:style_category1].blank? ? nil : value[:style_category1] , :style_category_id2 => value[:style_category2].blank? ? nil : value[:style_category2], :product_id => @product.id }])
            product_style = ProductStyle.new(:style_category_id1 => value[:style_category1],
                                             :style_category_id2 => value[:style_category2], 
                                             :product_id => @product.id)
          end
          if product_style[:id]
            product_style.update_attributes({:sell_price=>value[:sell_price], 
                                             :code=>value[:code],
                                             :manufacturer_id=>value[:manufacturer_id]})
          else
            [:sell_price, :code ,:manufacturer_id].each do |column|  
              product_style[column] = value[column]
            end
            product_style[:position] = idx.to_i + 1
          end
          @product_styles << product_style
          unless product_style.valid?
            @save_flg = false
            @error_messages ||= ""
            @error_messages += "#{idx.to_i + 1}行目が不正です。"
          end
        end
      end
    end
  end

end
