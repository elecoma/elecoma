class AccountsController < BaseController
  before_filter :login_check, :except => [
    :activate, :kiyaku, :kiyaku_intro, :login, :logout, :reminder,
    :reminder_complete, :reminder_hint, :salvage, :salvage_complete,
    :signup, :signup_complete, :signup_confirm,
    :regmailst, :get_address
  ]
  before_filter :load_seo_mypage_index, :only => [:history, :history_list, :edit, :delivery, :withdraw]
  before_filter :redirect_for_login_user, :only => [
    :login, :signup, :signup_confirm, :signup_complete, :kiyaku, :kiyaku_intro, :salvage, :salvage_complete
  ]

  EMAIL_PATTERN = /^(([^@\s]+)@((?:[-a-z0-9]+\.)*[a-z]{2,})|)$/i

  def login
    if request.request_method == :post
      if params[:customer]
        if params[:customer][:email] == ''
          flash.now[:notice] = "メールアドレスを入力して下さい。"
          return
        end
        if params[:customer][:password] == ''
          flash.now[:notice] = "パスワードを入力して下さい。"
          return
        end
      else
        flash.now[:notice] = "メールアドレスを入力してください"
        return
      end
      customer = Customer.find_by_email_and_password(params[:customer][:email], params[:customer][:password])
      if customer.nil?
        flash.now[:notice] = "メールアドレスもしくはパスワードが正しくありません。"
        return
      elsif customer.activate == Customer::KARITOUROKU
        flash.now[:notice] = '会員登録が完了していません。登録確認メールに書かれた URL にアクセスして会員登録を完了してください。'
      elsif !customer.same_mobile_carrier?(request.mobile)
        flash.now[:notice] = '登録時の端末でログインしてください。'
      else
        set_login_customer(customer)
        # ログイン前に買い物していれば、その内容を取り込む
        unless @carts.empty?
          Cart.delete_all(['customer_id=?', customer.id])
          @carts.each_with_index do |cart, i|
            cart.customer = customer
            cart.position = i
            cart.save
          end
        end
        unless params[:reminder_id].blank?
          cookies[:reminder_id] = {
            :value => customer.email,
            :expires => 14.days.from_now,
            :path => '/'
          }
          customer.save
        end
        unless params[:auto_login].blank?
          cookies[:auto_login] = {
            :value => customer.generate_cookie!(request.remote_ip),
            :expires => 14.days.from_now,
            :path => '/'
          }
          customer.save
        end
        # 直前にいたページ or トップページへリダイレクト
        if session[:return_to]
          # login_check で飛ばされた場合
          redirect_to :controller=>session[:return_to]["controller"],
                      :action=>session[:return_to]["action"],
                      :action=>session[:return_to]["dir_name"],
                      :id=>session[:return_to][:id]
          session[:return_to] = nil
        else
          # 普通に来た場合
          if request.mobile?
            redirect_to :controller => "accounts", :action=>"myindex_mobile"# '/account/myindex_mobile'
          else
            redirect_to :controller => "portal", :action => "show"
          end
        end
      end
    else
      if (cookie = cookies[:reminder_id])
        @customer = Customer.new(:email => cookie)
        @reminder_id = 1
      end
      if (cookie = cookies[:auto_login])
        @customer = Customer.find_by_cookie(cookie)
        @auto_login = 1
      end
    end
  end

  def logout
    @login_customer.update_attributes(:cookie => nil) unless @login_customer.cookie.nil?
    session[:carts] = nil
    set_login_customer(nil)
    request.env["HTTP_REFERER"] ||= url_for(:controller=>:portal, :action=>:show)
    redirect_to :back
  end

  # モバイル専用規約入口
  def kiyaku_intro
    redirect_to :action => :kiyaku unless request.mobile?
  end

  def kiyaku
    params[:position] ||= 1 if request.mobile?
    # 章を指定されたらそこだけ出す。さもなくば全て。
    if params[:position]
      kiyaku = Kiyaku.find_by_position(params[:position])
      raise ActiveRecord::RecordNotFound if kiyaku.nil?
      @next = Kiyaku.minimum(:position, :conditions => ['position > ?', kiyaku.position])
      @prev = Kiyaku.maximum(:position, :conditions => ['position < ?', kiyaku.position])
      @kiyakus = [kiyaku]
    else
      @kiyakus = Kiyaku.find(:all, :order=>'position')
      @kiyaku_content = ''
      @kiyakus.each do |k|
        @kiyaku_content = @kiyaku_content + k.name + "\n\n" + k.content + "\n\n"
      end
    end
  end

  def signup
    @stage = (params[:stage] || 0).to_i
    params[:done] && !params[:back] and return signup_confirm
    @customer = Customer.new
    if request.method == :post # 2 ページ目とか
      get_customer
    end
  end

  def signup_confirm
    @customer = Customer.new
    get_customer
    @customer.editting = false if request.mobile?
    unless @customer.valid?
      render :action => :signup
      return
    end
    @password = @customer.raw_password
    render :action => :signup_confirm
  end

  def signup_complete
    if params[:back]
      signup
      return render(:action => 'signup')
    end

    @customer = Customer.new(params[:customer])
    unless params[:password].blank?
      @customer.set_password params[:password]
    end

    # モバイル
    @customer.set_mobile request.mobile

    # 登録直後は仮登録状態
    # 登録キーを生成してメールを送る
    @customer.activate = Customer::KARITOUROKU
    @customer.generate_activation_key!

    # カートを保存
    @customer.carts.clear
    @customer.carts << @carts

    #ポイント付与
    unless Shop.find(:first).blank?
      @customer.point = Shop.find(:first).point_at_admission
    end

    unless @customer.valid?
      render :action => 'signup'
      return
    end

    begin
      url = url_for(:action => :activate, :activation_key => @customer.activation_key, :aff_id=>session[:aff_id])
      logger.debug "######## #{url} ########"
      Notifier::deliver_activate(@customer, url)
    rescue => e
      flash.now[:error] = 'メールの送信に失敗しました'
      render :action => 'signup'
      return
    end

    # 全てが終わったら保存
    @customer.save
  end

  # 購入履歴
  def history
    history_list
    render :action => 'history_list'
  end

  def history_list
    # paginate する
    @orders = Order.paginate(:page => params[:page],
                             :per_page => request.mobile ? 5 : 20,
                             :conditions => ['customer_id=?', @login_customer.id],
                             :order=>'received_at desc',
                             :limit => 20)
    @orders.total_entries = 20 if request.mobile? && @orders.total_entries > 20
  end

  def history_show
    @order = @login_customer.orders.find_by_id(params[:id])
    raise ActiveRecord::RecordNotFound unless @order
    @order_delivery = @order.order_deliveries[0]
  end

  # 会員登録内容変更
  def edit
    @stage = (params[:stage] || 0).to_i
    params[:done] && !params[:back] and return edit_confirm
    @customer = Customer.find(@login_customer.id)
    if request.method == :get # 1 ページ目
      @customer.email_confirm = @customer.email
      if request.mobile?
        @customer.email_user, @customer.email_domain = @customer.email.split('@', 2)
        @customer.email_user_confirm = @customer.email_user
      end
    end
    if request.method == :post # 2 ページ目とか
      get_customer
    end
  end

  def edit_confirm
    @customer = Customer.find(@login_customer.id)
    get_customer
    @customer.editting = false if request.mobile?
    unless @customer.valid?
      render :action => :edit
      return
    end
    # 入力が正しい時だけ次へ引き継ぐ
    @password = @customer.raw_password
    render :action => :edit_confirm
  end

  def edit_complete
    if params[:back]
      edit
      return render(:action => 'edit')
    end
    @customer = Customer.find(@login_customer.id)
    @customer.attributes = params[:customer]
    unless @customer.valid?
      render :action => 'edit'
      return
    end
    @customer.set_mobile request.mobile
    @customer.save
    set_login_customer(@customer)
  end

  def delivery
    @delivery_addresses = @login_customer.delivery_addresses
    render :action => 'delivery_list'
  end

  def delivery_list
    redirect_to :action => :delivery
  end

  def delivery_new
    @stage = (params[:stage] || 0).to_i
    params[:done] && !params[:back] and return delivery_create
    @delivery_address = @login_customer.delivery_addresses.build
    if request.method == :post
      get_delivery_address
    end
    render :action => 'delivery_new' unless performed?
  end

  def delivery_new_popup
    @popup = true
    delivery_new
    render :action => 'delivery_new_popup' unless performed?
  end

  def delivery_create
    @stage = params[:stage]
    @popup = !params[:popup].blank? && params[:popup] == "true"
    customer = @login_customer
    @delivery_address = customer.delivery_addresses.build(params[:delivery_address])
    unless @delivery_address.valid?
      return render(:action => 'delivery_new')
    end
    render :action => 'delivery_confirm'
  end

  def delivery_edit
    @stage = (params[:stage] || 0).to_i
    params[:done] && !params[:back] and return delivery_update
    @id = params[:id].to_i
    @delivery_address = find_delivery_address @login_customer, params[:id]
    if request.method == :post
      get_delivery_address
    end
    render :action => 'delivery_edit' unless performed?
  end

  def delivery_edit_popup
    @popup = true
    delivery_edit
    render :action => 'delivery_edit_popup' unless performed?
  end

  def delivery_update
    @popup = !params[:popup].blank? && params[:popup] == "true"
    @id = params[:id].to_i
    @delivery_address = find_delivery_address @login_customer, params[:id]
    @delivery_address.attributes = params[:delivery_address]
    unless @delivery_address.valid?
      return render(:action => 'delivery_edit')
    end
    if @popup
      render :action => 'delivery_confirm_popup'
    else
      render :action => 'delivery_confirm'
    end
  end

  def delivery_complete
    @popup = !params[:popup].blank? && params[:popup] == "true"
    if params[:id].blank?
      # 新規
      if params[:back]
        return (@popup ? delivery_new_popup : delivery_new)
      end
      @delivery_address = @login_customer.delivery_addresses.build()
      # 最大の position + 1 を割り当てる
      max_position = @login_customer.delivery_addresses.map(&:position).map(&:to_i).max
      @delivery_address.position = max_position + 1
    else
      # 更新
      if params[:back]
        return (@popup ? delivery_edit_popup : delivery_edit)
      end
      @delivery_address = find_delivery_address @login_customer, params[:id]
    end
    @delivery_address.attributes = params[:delivery_address] if @delivery_address
    if @delivery_address && @delivery_address.save
      flash.now[:notice] = 'データを保存しました。'
    else
      flash.now[:error] = 'データの保存に失敗しました。'
    end
    if @popup
      render :action => 'close_popup'
    else
      if params[:backurl] # カートから来た時
        redirect_to :controller => 'cart', :action => 'shipping'
      else
        redirect_to :action => 'delivery'
      end
    end
  end

  def delivery_destroy
    @delivery_address = find_delivery_address @login_customer, params[:id]
    if @delivery_address and @delivery_address.destroy
      flash.now[:notice] = '削除しました。'
    else
      flash.now[:notice] = '削除に失敗しました。'
    end
    if params[:backurl] # カートから来た時
      redirect_to params[:backurl]
    else
      redirect_to :action => 'delivery'
    end
  end

  def activate
    key = params[:activation_key]
    unless key.blank?
      @customer = Customer.activate_email(key)
      @customer.reachable = true
      if @customer
        save_carts(@customer.carts)
        @customer.carts.clear
      end
    end
  end

  def withdraw
  end

  def withdraw_confirm
  end

  def withdraw_complete
    unless request.post?
      head :method_not_allowed
      return
    end
    @login_customer.withdraw
    set_login_customer(nil)
  end

  def reminder
    redirect_to :action => :salvage
  end

  def salvage
    flash.now[:notice] = flash.now[:error] = nil
  end

  def salvage_complete
    @input = Customer.new(params[:input])
    @customer = Customer.find_by_email_and_activate(@input.email, Customer::TOUROKU)
    @input.id = @customer.id if @customer # メールアドレス重複エラー回避
    columns = [:email, :family_name, :first_name, :birthday, :tel01, :tel02, :tel03]
    @input.attributes = {:password_confirm=>"dummy", :email_confirm=>"dummy@example.com"}
    @input.target_columns = columns
    unless @input.valid?
      render :action => "salvage"
      return
    end
    correct = @customer && columns.all?{ |c| @customer[c] == @input[c] }
    unless correct
      flash.now[:notice] = "入力された情報が正しくありません"
      render :action => "salvage"
      return
    end
    @password = @customer.regenerate_password!
    unless @customer.save
      flash.now[:notice] = "パスワードの再発行に失敗しました"
      render :action => "salvage"
      return
    end
    #メールの送信
    begin
      if request.mobile?
        Notifier::deliver_mobile_reminder(@customer, @password)
      else
        Notifier::deliver_reminder(@customer, @password)
      end
    rescue
      flash.now[:notice] = "メールの送信に失敗しました"
      render :action => "salvage"
      return
    end
  end

  def regmailst
    @target_domain = Shop.first.docomo_sender_address
    @return_to = params[:return_to]
    @return_to ||= request.env["HTTP_REFERER"]
    @return_to ||= url_for(:action=>:kiyaku_intro, :only_path => false)
  end

  private

  def get_shop_info
    @shop = Shop.find(:first)
  end

  def find_customer_by_email(email)
    customer = Customer.find_by_email(email)
    return customer
  end

  def find_delivery_address customer, id
    id or raise ActiveRecord::RecordNotFound
    conditions = ["#{DeliveryAddress.table_name}.id = ? and #{Customer.table_name}.id = ?",
      id, customer.id]
    da = DeliveryAddress.find(:first, :conditions => conditions, :include => :customer)
    da or raise ActiveRecord::RecordNotFound
  end

  def load_seo_mypage_index
    @seo = Seo.find(:first, :conditions=>{ :page_type => Seo::MYPAGE_INDEX})
  end

  def get_delivery_address
    @popup ||= !params[:popup].blank? && params[:popup] == "true"

    @delivery_address.attributes = params[:delivery_address]||{}
    if params[:back]
      @delivery_address.target_columns = []
      @stage -= 1
      if @stage < 0
        if @popup
          redirect_to :controller => :cart, :action => :shipping
        else
          redirect_to :action => :delivery
        end
      end
      return
    end
    if params[:delivery_address]
      @delivery_address.target_columns = params[:delivery_address].keys.map(&:to_s)
    end
    #@delivery_address.update_address!(@delivery_address.zipcode_first_changed?)
    @delivery_address.update_address!
    @stage += 1 if @delivery_address.valid?
  end

  def get_customer
    @customer.attributes = params[:c] if params[:c]
    if params[:customer]
      @customer.attributes = params[:customer]
      @customer.target_columns = params[:customer].keys.map(&:to_s)
    end
    @customer.set_mobile request.mobile # 携帯電話の種類
    @customer.editting = true
    if params[:back]
      @customer.target_columns = []
      @stage -= 1
      return
    end
    @customer.update_address!(false)
    @stage += 1 if @customer.valid? && @stage
  end

  def redirect_for_login_user
    redirect_to :controller => :portal, :action => :show if @login_customer
  end

end
