class Admin::AuthoritiesController < Admin::BaseController
  #共通
  resource_controller
  before_filter :admin_permission_check_member
  before_filter :master_shop_check

  #indexの前処理
  index.before do
    @authorities = Authority.find(:all,
                                  :order => 'position')
  end

  #editの前処理
  edit.before do
    #get authority.functions
    @selected_functions = @authority.functions.map{|f| f.id}
  end


  def create
    save(false)
  end

  def update
    save(true)
  end

  #上へ
  def up
    super
    redirect_to :action => "index"
  end
  #下へ
  def down
    super
    redirect_to :action => "index"
  end

  private
  def save(type)

    if type
      back_to = "edit"
      @authority = Authority.find_by_id(params[:id])
      @authority.attributes = params[:authority]
    else
      back_to = "new"
      @authority = Authority.new(params[:authority])
    end

    if @authority.save
      #authority.functions 保存
      @authority.chang_functions(params[:functions] || {})
      flash.now[:notice] = "データを保存しました。"
      redirect_to :action => :index
    else
      #エラーがある場合
      if params[:functions]
        @selected_functions = params[:functions].keys.collect {|key| key.to_i}
      end
      flash.now[:notice] = "エラーが発生しました。"
      render  :action => back_to
      return
    end
  end

end
