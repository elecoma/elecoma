class Admin::SuppliersController < Admin::BaseController
  #共通
  resource_controller
  before_filter :admin_permission_check_supplier
  before_filter :check_supplier_use
  before_filter :check_default,:only => [:edit,:confirm]
  
  def search
    @condition = SupplierSearchForm.new(params[:condition])
    unless @condition.valid?
      render :action => "index"
      return
    end

    sql_condition, conditions = SupplierSearchForm.get_sql_condition(@condition)
    sql = SupplierSearchForm.get_sql_select + sql_condition
    sqls = [sql]
    conditions.each do |c|
      sqls << c
    end
    @suppliers = Supplier.paginate_by_sql(sqls,
                                          :page => params[:page],
                                          :per_page => @condition.per_page ||10,
                                          :order => "id")  
  end
  
  edit.before do
    get_supplier    
  end
  
  #確認画面
  def confirm
    if !params[:id].blank?
      get_supplier
    else  
      @supplier = Supplier.new(params[:supplier])
    end
    #入力チェック
    unless @supplier.valid?
      if !params[:id].blank?
        render :action => :edit
      else
        render :action => :new
      end
      return
    end
  end
  #遷移先指定  
  [create, update,destroy].each do |action|
    action.wants.html do
      redirect_to :action => "index"
    end
  end
  #仕入先を使用しているかしないと判断のフィルタ
  def check_supplier_use
    unless @system.supplier_use_flag
      redirect_to :controller=>"/admin/home"
      return
    end
  end
  #編集・削除の時、ID=1かどうかチェック
  #ID=1のデータは編集不可、削除不可にさせる
  def check_default
    if params[:id].to_i == Supplier::DEFAULT_SUPPLIER_ID
      redirect_to :controller=>"/admin/suppliers"
      return
    end
  end
  private
  def get_supplier
      @supplier = Supplier.find_by_id(params[:id])
      @supplier.attributes = params[:supplier]    
  end  
end
