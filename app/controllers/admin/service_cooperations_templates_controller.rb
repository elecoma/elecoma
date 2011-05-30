class Admin::ServiceCooperationsTemplatesController < Admin::BaseController

  def index
    @templates = ServiceCooperationsTemplate.all
  end

  def new
    @service_cooperations_template = ServiceCooperationsTemplate.new
  end

  def edit
    @service_cooperations_template = ServiceCooperationsTemplate.find_by_id(params[:id])
    if @service_cooperations_template.nil?
      flash[:notice] = '無効なidが渡されました'
      redirect_to :action => 'index'
    end
  end

  def confirm
    @service_cooperations_template = ServiceCooperationsTemplate.find_by_id(params[:id]) || ServiceCooperationsTemplate.new
    @service_cooperations_template.attributes = params[:service_cooperations_template]
    unless @service_cooperations_template.valid?
      if params[:id].blank?
        render :action => "new"
      else
        render :action => "edit"
      end
      return
    end
  end

  def create
    @service_cooperations_template = ServiceCooperationsTemplate.new(params[:service_cooperations_template])

    if @service_cooperations_template.save
      flash[:notice] = 'テンプレートは正常に追加されました'
      redirect_to :action => "index"
    else
      flash[:notice] = 'エラーが発生しました'
      render :action => "new"
    end
  end

  def update
    @service_cooperations_template = ServiceCooperationsTemplate.find_by_id(params[:id])
    @service_cooperations_template.attributes = params[:service_cooperations_template]
    if @service_cooperations_template.save
      flash[:notice] = 'テンプレートは正常に更新されました'
      redirect_to :action => "index"
    else
      flash[:notice] = 'エラーが発生しました'
      render :action => "edit"
    end
  end

  def destroy
    service_template = ServiceCooperationsTemplate.find_by_id(params[:id])
    if service_template
      service_template.destroy
    else
      flash[:notice] = '削除に失敗しました 無効なidです'
    end
    redirect_to :action => 'index'
  end
end
