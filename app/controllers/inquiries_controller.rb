class InquiriesController < BaseController
  before_filter :init_by_params, :only=>[:new, :confirm, :complete]

  def show
    @shop = Shop.find(:first)
  end

  def new
  end

  def confirm

    unless @inquiry.valid?
      @inquiry.email = params[:inquiry][:email]
      render :action => "new"
      return
    end
  end

  def complete

    #メール送信処理
    begin
      @inquiry.save!
      request.mobile? ? Notifier::deliver_received_inquiry(@inquiry,true) : Notifier::deliver_received_inquiry(@inquiry,false)
      request.mobile? ? Notifier::deliver_mobile_inquiry(@inquiry) : Notifier::deliver_pc_inquiry(@inquiry)
      flash.now[:notice] = "お問い合わせを送信しました"
    rescue
      flash.now[:notice] = "お問い合わせ送信に失敗しました"
      render :action => "new"
      return
    end
  end

  def privacy
    @privacy = Privacy.first
  end

  private

  def init_by_params
    if params[:inquiry]
      @inquiry = Inquiry.new params[:inquiry]
      @inquiry.kind = params[:inquiry][:kind].to_i if params[:inquiry][:kind]
    else
      @inquiry = Inquiry.new
      if request.mobile?
        #携帯のドメインを表記
        if request.mobile.instance_of?(Jpmobile::Mobile::Docomo)
          @inquiry.email = "@docomo.ne.jp"
        elsif request.mobile.instance_of?(Jpmobile::Mobile::Au)
          @inquiry.email = "@ezweb.ne.jp"
        end
      end
      @inquiry.kind = Inquiry::GOODS
    end
  end
end
