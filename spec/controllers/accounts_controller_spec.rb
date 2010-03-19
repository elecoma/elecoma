# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe AccountsController do
  fixtures :customers, :kiyakus, :carts, :product_styles, :products, :delivery_addresses, :campaigns

  before do
    @controller.class.skip_before_filter :start_transaction
    @controller.class.skip_after_filter :end_transaction
  end

  #Delete these examples and add some real ones
  it "should use AccountsController" do
    controller.should be_an_instance_of(AccountsController)
  end


  describe "GET 'login'" do
    it "should be successful" do
      get 'login'
      response.should be_success
    end
  end

  describe "GET 'logout'" do
    fixtures :customers
    it "ログアウトする" do
      session[:customer_id] = customers(:valid_signup).id
      get 'logout'
      response.should be_redirect
      session[:customer_id].should be_nil
    end
  end

  describe "GET 'signup'" do
    it "should be successful" do
      get 'signup'
      response.should be_success
    end
  end

  describe "POST 'signup_confirm'" do
    fixtures :customers
    before do
      @new_customer = Customer.new(customers(:valid_signup).attributes)
      # メールアドレスが被るので変える
      @new_customer.email.succ!
      @param_customer = @new_customer.attributes
      @param_customer['email_confirm'] = @new_customer.email
      @param_customer['raw_password'] = 'password'
      @param_customer['password_confirm'] = 'password'
    end

    it "should be successful" do
      customer = @new_customer
      @param_customer['email'] = "test10@example.com"
      @param_customer['email_confirm'] = "test10@example.com"
      post 'signup_confirm', :customer => @param_customer
      response.should be_success
      response.should render_template('signup_confirm')
      assigns[:customer].should_not be_nil
      assigns[:password].should == 'password'
    end

    it "should not be successful" do
      customer = customers(:invalid_signup)
      post 'signup_confirm', :customer => @param_customer.merge(customer.attributes)
      response.should render_template('signup')
      assigns[:customer].first_name.should == customer.first_name
      assigns[:customer].family_name.should == customer.family_name
      assigns[:customer].zipcode01.should == customer.zipcode01
    end

    it "メールアドレスの確認でひっかかる場合" do
      @param_customer['email_confirm'] = @param_customer['email'].succ
      post 'signup_confirm', :customer => @param_customer
      response.should render_template('signup')
      assigns[:customer].email.should == @param_customer['email']
      assigns[:customer].email_confirm.should == @param_customer['email_confirm']
    end

    it "パスワードの確認でひっかかる場合" do
      @param_customer['password_confirm'].succ!
      post 'signup_confirm', :customer => @param_customer
      response.should render_template('signup')
      assigns[:customer].raw_password.should == @param_customer['raw_password']
      assigns[:customer].password_confirm.should == @param_customer['password_confirm']
    end

    it "既存会員とメールアドレスが被る" do
      customer = @new_customer
      customer.email = customers(:mail_check).email
      post 'signup_confirm', :customer => customer.attributes,
                             :email_confirm => customer.email,
                             :password => 'password',
                             :password_confirm => 'password'
      response.should render_template('signup')
      assigns[:customer].should have_at_least(1).errors_on(:email)
    end

    it "退会済みユーザとメールアドレスが被る" do
      @param_customer['email'] = customers(:withdrawn_customer).email
      @param_customer['email_confirm'] = @param_customer['email']
      post 'signup_confirm', :customer => @param_customer
      assigns[:customer].should have_at_most(0).errors_on(:email)
    end

    it "携帯電話のメールアドレス" do
      request.user_agent = "DoCoMo/2.0 SH903i(c100;TB;W24H16)"
      sjis_params = {}
      customer = @new_customer
      customer.attributes.each do | key, value |
        sjis_params[key] = value.to_s unless value.nil?
      end
      sjis_params['email_user'] = 'spammer'
      sjis_params['email_user_confirm'] = 'spammer'
      sjis_params['email_domain'] = 'docomo.ne.jp'
      sjis_params['raw_password'] = 'password'
      sjis_params['password_confirm'] = 'password'
      post 'signup_confirm', :customer => sjis_params
      assigns[:customer].email.should == 'spammer@docomo.ne.jp'
    end

  end

  describe "GET 'signup_complete'" do
    it "should be successful" do
      get 'signup_complete'
      response.should be_success
    end

  end

  describe "POST 'signup_complete'" do
    fixtures :customers
    before do
      @new_customer = Customer.new customers(:valid_signup).attributes
      # メールアドレスが被るので変える
      @new_customer.email.succ!
      @param_customer = @new_customer.attributes.merge({
        'raw_password' => 'password', 
        'password_confirm' => 'password',
        'email_confirm' => @new_customer.email
      })
      # メール送信はスタブを使う
      Notifier.stub!(:deliver_activate).and_return(nil)
    end

    it "should be successful" do
      post 'signup_complete', :customer => @param_customer
      response.should be_success
      response.should render_template('signup_complete')
    end

    it "should not be successful" do
      customer = customers :invalid_signup
      post 'signup_complete', :customer => customer.attributes, :password => 'password'
      response.should render_template('signup')
    end

    it "テーブルに登録される" do
      previous_count = Customer.find(:all).size
      @param_customer["email"] = "test1@example.com"
      @param_customer["email_confirm"] = "test1@example.com"
      post 'signup_complete', :customer => @param_customer
      response.should be_success
      response.should render_template('signup_complete')
      Customer.find(:all).size.should == previous_count + 1
    end

    it "まだログイン状態にならない" do
      @param_customer["email"] = "test2@example.com"
      @param_customer["email_confirm"] = "test2@example.com"
      post 'signup_complete', :customer => @param_customer
      response.should be_success
      response.should render_template('signup_complete')
      session[:customer_id].should be_nil
    end

    it "パスワードを暗号化して設定する" do
      @param_customer["email"] = "test3@example.com"
      @param_customer["email_confirm"] = "test3@example.com"
      post 'signup_complete', :customer => @param_customer
      response.should be_success
      response.should render_template('signup_complete')
      assigns[:customer].correct_password?('password').should be_true
    end

    it "登録直後は仮登録状態" do
      @param_customer["email"] = "test4@example.com"
      @param_customer["email_confirm"] = "test4@example.com"
      post 'signup_complete', :customer => @param_customer
      response.should be_success
      response.should render_template('signup_complete')
      assigns[:customer].activate.should == Customer::KARITOUROKU
    end

    it "登録キーを生成" do
      @param_customer["email"] = "test5@example.com"
      @param_customer["email_confirm"] = "test5@example.com"
      post 'signup_complete', :customer => @param_customer
      response.should be_success
      response.should render_template('signup_complete')
      assigns[:customer].activation_key.should_not be_nil
    end

    it "メールを送る" do
      @param_customer["email"] = "test6@example.com"
      @param_customer["email_confirm"] = "test6@example.com"
      Notifier.should_receive(:deliver_activate).and_return(nil)
      post 'signup_complete', :customer => @param_customer
      response.should render_template('signup_complete')
    end

    it "メール送信失敗" do
      @param_customer["email"] = "test7@example.com"
      @param_customer["email_confirm"] = "test7@example.com"
      Notifier.should_receive(:deliver_activate).and_raise 'error'
      post 'signup_complete', :customer => @param_customer
      response.should render_template('signup')
    end

    it "携帯電話" do
      @param_customer["email"] = "test8@docomo.ne.jp"
      @param_customer["email_confirm"] = "test8@docomo.ne.jp"
      request.user_agent = "DoCoMo/2.0 SH903i(c100;TB;W24H16)"
      sjis_params = {}
      @param_customer.each do | key, value |
        sjis_params[key] = value.to_s.tosjis unless value.nil?
      end
      post 'signup_complete', :customer => sjis_params
      response.should be_success
      response.should render_template('signup_complete_mobile')
      assigns[:customer].mobile_carrier.should == Customer::DOCOMO
    end

    it "携帯電話じゃない" do
      @param_customer["email"] = "test9@example.com"
      @param_customer["email_confirm"] = "test9@example.com"
      request.user_agent = "spam, spam, spam, spam and spam"
      post 'signup_complete', :customer => @param_customer
      response.should be_success
      assigns[:customer].valid?.should be_true
      response.should render_template('signup_complete')
      assigns[:customer].mobile_carrier.should == Customer::NOT_MOBILE
    end
  end

  # 購入履歴
  describe "GET 'history'" do
    fixtures :orders, :order_deliveries, :order_details
    before do
      @customer = customers(:have_orders)
      session[:customer_id] = @customer.id
    end

    it "should be successful" do
      get 'history'
      response.should be_success
    end

    it "should render 'history_list'" do
      get 'history'
      response.should be_success
      response.should render_template('history_list')
    end

    it "購入履歴を出す" do
      get 'history'
      response.should be_success
      assigns[:orders].should_not be_nil
      assigns[:orders].size.should == @customer.orders.size
    end

    it "受注日時の降順に出力" do
      get 'history'
      response.should be_success
      date = nil
      assigns[:orders].each do | order |
        order.received_at.should < date if date
        date = order.received_at
      end
    end
  end

  describe "GET 'history_show'" do
    fixtures :systems, :orders, :order_deliveries, :order_details
    before do
      @customer = customers(:have_orders)
      session[:customer_id] = @customer.id
      @order = @customer.orders[0]
      @order.order_deliveries.each(&:calculate_total!)
    end

    it "should be successful" do
      get 'history_show', :id => @order.id
      response.should be_success
    end

    it "should render 'history_show'" do
      get 'history_show', :id => @order.id
      response.should be_success
      response.should render_template('history_show')
    end

    it "指定された id の Order を表示" do
      get 'history_show', :id => @order.id
      response.should be_success
      assigns[:order].should == @order
    end

    it "1 件目の OrderDelivery を表示" do
      get 'history_show', :id => @order.id
      response.should be_success
      assigns[:order].should == @order
      assigns[:order_delivery].should == @order.order_deliveries[0]
    end

    it "無関係な id" do
      get 'history_show', :id => 99294
      response.should_not be_success
    end
  end

  describe "GET 'edit'" do
    it "非ログイン時は表示できない" do
      get 'edit'
      response.should redirect_to(:action => 'login')
    end
  end

  describe "GET 'edit'" do
    fixtures :customers
    before do
      @customer = customers(:valid_signup)
      session[:customer_id] = @customer.id
    end

    it "should be successful" do
      get 'edit'
      response.should be_success
      response.should render_template('edit')
      assigns[:customer].id.should == @customer.id
      assigns[:customer].first_name.should == @customer.first_name
    end

    it "メールアドレス確認" do
      get 'edit'
      response.should be_success
      response.should render_template('edit')
      assigns[:customer].email_confirm.should == @customer.email
    end

    it "モバイルメールアドレス確認" do
      request.user_agent = "DoCoMo/2.0 SH903i(c100;TB;W24H16)"
      get 'edit'
      m = @customer.email.match(/^([^@]+)/)
      email_user = m[1]
      response.should be_success
      response.should render_template('edit_mobile')
      assigns[:customer].email_user.should == email_user
      assigns[:customer].email_user_confirm.should == email_user
    end

    it "パスワード初期値無し" do
      get 'edit'
      response.should be_success
      response.should render_template('edit')
      assigns[:password].should be_blank
    end

    it "パスワード確認初期値無し" do
      get 'edit'
      response.should be_success
      response.should render_template('edit')
      assigns[:password_confirm].should be_blank
    end

  end

  describe "GET 'edit_confirm'" do
    it "非ログイン時は表示できない" do
      get 'edit_confirm'
      response.should redirect_to(:action => 'login')
    end
  end

  describe "POST 'edit_confirm'" do
    fixtures :customers
    before do
      @customer = customers(:valid_signup)
      session[:customer_id] = @customer.id
      @param_customer = @customer.attributes
      @param_customer['email_confirm'] = @customer.email
    end

    it "should be successful" do
      @param_customer['raw_password'] = 'password'
      @param_customer['password_confirm'] = 'password'
      post 'edit_confirm', :customer => @param_customer
      response.should be_success
      response.should render_template('edit_confirm')
      assigns[:customer].should_not be_nil
    end

    it "入力された内容を表示する" do
      customer = @param_customer
      customer['email'] = 'foobarbaz@example.com'
      customer['email_confirm'] = customer['email']
      post 'edit_confirm', :customer => customer
      puts assigns[:customer].errors.full_messages
      response.should be_success
      response.should render_template('edit_confirm')
      assigns[:customer].should_not be_nil
      assigns[:customer].email.should == customer['email']
      # ログイン中の情報はまだ更新しない
      Customer.find(session[:customer_id]).should_not == customer['email']
    end

    it "should not be successful" do
      @param_customer['email'] = 'foooo'
      post 'edit_confirm', :customer => @param_customer
      assigns[:customer].should_not be_nil
      assigns[:customer].should_not be_valid
      response.should render_template('edit')
    end

    it "パスワードを入力していない場合は通る" do
      old_password = @customer.password
      post 'edit_confirm', :customer => @param_customer
      response.should be_success
      response.should render_template('edit_confirm')
    end

    it "入力されたパスワードを次へ引き継ぐ" do
      new_password = 'qwertyuiop'
      @param_customer['raw_password'] = new_password
      @param_customer['password_confirm'] = new_password
      post 'edit_confirm', :customer => @param_customer
      response.should be_success
      assigns[:password].should == new_password
    end

    it "パスワードが一致しない" do
      new_password = 'qwertyuiop'
      @param_customer['raw_password'] = new_password
      @param_customer['password_confirm'] = 'zzzzzzzzzzzz'
      post 'edit_confirm', :customer => @param_customer
      assigns[:customer].errors.on(:password).should_not be_nil
      response.should render_template('edit')
    end

    it "パスワードが一致しない場合は引き継がない" do
      new_password = 'qwertyuiop'
      @param_customer['raw_password'] = new_password
      @param_customer['password_confirm'] = 'zzzzzzzzzzzz'
      post 'edit_confirm', :customer => @param_customer
      assigns[:customer].errors.on(:password).should_not be_nil
      response.should render_template('edit')
      assigns[:password].should be_blank
    end

  end

  describe "GET 'edit_complete'" do
    it "非ログイン時は表示できない" do
      get 'edit_complete'
      response.should redirect_to(:action => 'login')
    end
  end

  describe "POST 'edit_complete'" do
    fixtures :customers
    before do
      @customer = customers(:valid_signup)
      session[:customer_id] = @customer.id
    end

    it "should be successful" do
      post 'edit_complete', :customer => @customer.attributes
      response.should be_success
      response.should render_template('edit_complete')
      assigns[:customer].should_not be_nil
      session[:customer_id].should_not be_nil
    end

    it "should be successful" do
      post 'edit_complete', :customer => customers(:invalid_signup).attributes
      response.should render_template('edit')
      assigns[:customer].should_not be_nil
      session[:customer_id].should_not be_nil
    end

    it "入力内容をセッションに反映する" do
      customer = @customer.attributes
      customer['first_name'] = '登録内容変更後'
      post 'edit_complete', :customer => customer
      response.should be_success
      response.should render_template('edit_complete')
      assigns[:customer].should_not be_nil
      session[:customer_id].should_not be_nil
      Customer.find(session[:customer_id]).first_name.should == customer['first_name']
    end

    it "ID を入力されても別のユーザを更新しない" do
      customer = @customer.attributes
      newid = customers(:invalid_signup).id
      customer['first_name'] = '登録内容変更後'
      customer['id'] = newid
      post 'edit_complete', :customer => customer
      response.should be_success
      response.should render_template('edit_complete')
      assigns[:customer].should_not be_nil
      session[:customer_id].should_not be_nil
      Customer.find(newid).first_name.should_not == customer['first_name']
    end

    it "新パスワードを入力された場合は変更する" do
      old_password = @customer.password
      customer = @customer.attributes
      customer["raw_password"] = 'password'
      customer["password_confirm"] = 'password'
      post 'edit_complete', :customer => customer
      response.should be_success
      response.should render_template('edit_complete')
      assigns[:customer].should_not be_nil
      session[:customer_id].should_not be_nil
      session_customer = Customer.find(session[:customer_id])
      session_customer.password.should_not == old_password
      session_customer.correct_password?('password').should be_true
    end

    it "新パスワードを入力されない場合は変更しない" do
      old_password = @customer.password
      post 'edit_complete', :customer => @customer.attributes
      response.should be_success
      response.should render_template('edit_complete')
      assigns[:customer].should_not be_nil
      session[:customer_id].should_not be_nil
      Customer.find(session[:customer_id]).password.should == old_password
    end

  end

  describe "GET 'delivery'" do
    fixtures :customers, :delivery_addresses
    before do
      @customer = customers(:have_delivary_address)
      session[:customer_id] = @customer.id
    end

    it "should be successful" do
      get 'delivery'
      response.should be_success
      response.should render_template('delivery_list')
      assigns[:delivery_addresses].should == @customer.delivery_addresses
    end

    it "position 順に並ぶ" do
      get 'delivery'
      response.should be_success
      response.should render_template('delivery_list')
      assigns[:delivery_addresses].should == @customer.delivery_addresses
      previous_position = 0
      assigns[:delivery_addresses].each do |address|
        address.position.should > previous_position
        previous_position = address.position
      end
    end
  end


  describe "GET 'delivery_new'" do
    fixtures :customers, :delivery_addresses
    before do
      @customer = customers(:have_delivary_address)
      session[:customer_id] = @customer.id
    end

    it "should be successful" do
      get 'delivery_new' 
      response.should be_success
      response.should render_template('delivery_new')
      assigns[:delivery_address].should_not be_nil
    end
  end

  describe "POST 'delivery_create'" do
    fixtures :delivery_addresses
    before do
      @customer = customers(:have_delivary_address)
      session[:customer_id] = @customer.id
      #delivery_address = delivery_addresses(:optional_address3)
      delivery_address = DeliveryAddress.find(delivery_addresses(:optional_address3).id)      
      delivery_address.customer_id = customers(:have_delivary_address).id
      delivery_address.save!
    end

    it "should be successful" do
      new_address = delivery_addresses(:valid_address)
      post 'delivery_create', :delivery_address => new_address.attributes
      response.should render_template('delivery_confirm')
      assigns[:id].should be_nil
      assigns[:delivery_address].should_not be_nil
      assigns[:delivery_address].first_name.should == new_address.first_name
      assigns[:delivery_address].prefecture_id.should == new_address.prefecture_id
      assigns[:delivery_address].address_city.should == new_address.address_city
      assigns[:delivery_address].tel01.should == new_address.tel01
    end

    it "should not be successful" do
      new_address = delivery_addresses(:unvalid_address)
      post 'delivery_create', :delivery_address => new_address.attributes
      response.should render_template('delivery_new')
      assigns[:id].should be_nil
      assigns[:delivery_address].should_not be_nil
      assigns[:delivery_address].first_name.should == new_address.first_name
      assigns[:delivery_address].prefecture_id.should == new_address.prefecture_id
      assigns[:delivery_address].address_city.should == new_address.address_city
      assigns[:delivery_address].tel01.should == new_address.tel01
    end
  end

  describe "GET 'delivery_edit'" do
    it "should be successful" do
      delivery_address = delivery_addresses(:optional_address3)
      delivery_address.customer_id = customers(:have_delivary_address).id
      delivery_address.save!
      customer = customers(:have_delivary_address)
      customer = Customer.find_by_id(customer.id)
      session[:customer_id] = customer.id
      get 'delivery_edit', :id => customer.delivery_addresses[0].id
      response.should be_success
      response.should render_template('delivery_edit')
      assigns[:id].should == customer.delivery_addresses[0].id
      assigns[:delivery_address].should == customer.delivery_addresses[0]
    end
  end

  describe "POST 'delivery_update'" do
    fixtures :delivery_addresses
    before do
      delivery_address = delivery_addresses(:optional_address3)
      delivery_address.customer_id = customers(:have_delivary_address).id
      delivery_address.save!
    end
    it "should be successful" do
      customer = customers(:have_delivary_address)
      session[:customer_id] = customer.id
      old_address = customer.delivery_addresses[0]
      new_address = delivery_addresses :valid_address
      post 'delivery_update', :id => old_address.id, :delivery_address => new_address.attributes
      response.should render_template('delivery_confirm')
      assigns[:id].should == old_address.id
      assigns[:delivery_address].should_not be_nil
      assigns[:delivery_address].first_name.should == new_address.first_name
      assigns[:delivery_address].prefecture_id.should == new_address.prefecture_id
      assigns[:delivery_address].address_city.should == new_address.address_city
      assigns[:delivery_address].tel01.should == new_address.tel01
    end

    it "should not be successful" do
      customer = customers(:have_delivary_address)
      session[:customer_id] = customer.id
      old_address = customer.delivery_addresses[0]
      new_address = delivery_addresses :unvalid_address
      post 'delivery_update', :id => old_address.id, :delivery_address => new_address.attributes
      response.should render_template('delivery_edit')
      assigns[:id].should == old_address.id
      assigns[:delivery_address].should_not be_nil
      assigns[:delivery_address].first_name.should == new_address.first_name
      assigns[:delivery_address].prefecture_id.should == new_address.prefecture_id
      assigns[:delivery_address].address_city.should == new_address.address_city
      assigns[:delivery_address].tel01.should == new_address.tel01
    end
  end

  describe "GET 'delivery_complete'" do
    fixtures :delivery_addresses
    before do
      @customer = customers(:have_delivary_address)
      session[:customer_id] = @customer.id
      delivery_address = delivery_addresses(:optional_address3)
      delivery_address.customer_id = customers(:have_delivary_address).id
      delivery_address.save!
    end

    it 'create から来た場合' do
      new_address = delivery_addresses(:invalid_address2)
      post 'delivery_complete', :delivery_address => new_address.attributes
      response.should redirect_to(:action => 'delivery')
      assigns[:delivery_address].should_not be_nil
      assigns[:delivery_address].first_name.should == new_address.first_name
      assigns[:delivery_address].prefecture_id.should == new_address.prefecture_id
      assigns[:delivery_address].address_city.should == new_address.address_city
      assigns[:delivery_address].tel01.should == new_address.tel01
    end

    it "最大の position + 1 を割り当てる" do
      max_position = @customer.delivery_addresses.map(&:position).max
      new_address = delivery_addresses(:valid_address)
      post 'delivery_complete', :delivery_address => new_address.attributes
      response.should redirect_to(:action => 'delivery')
      created_address = DeliveryAddress.find(
        :first, :conditions => ['position = ?', max_position + 1])
      created_address.should_not be_nil
      created_address.position.should == max_position + 1
    end

    it "追加失敗" do
      new_address = delivery_addresses(:unvalid_address)
      post 'delivery_complete', :delivery_address => new_address.attributes
      response.should redirect_to(:action => 'delivery')
    end

    it 'update から来た場合' do
      customer = customers(:have_delivary_address)
      session[:customer_id] = customer.id
      old_address = customer.delivery_addresses[0]
      new_address = delivery_addresses :valid_address
      post 'delivery_complete', :id => old_address.id, :delivery_address => new_address.attributes
      response.should redirect_to(:action => 'delivery')
      updated_address = DeliveryAddress.find(old_address.id)
      updated_address.first_name.should == new_address.first_name
      updated_address.prefecture_id.should == new_address.prefecture_id
      updated_address.address_city.should == new_address.address_city
      updated_address.tel01.should == new_address.tel01
    end

    it '不正な ID を与えられた場合' do
      customer = customers(:have_delivary_address)
      session[:customer_id] = customer.id
      unrelated_address = delivery_addresses(:valid_address)
      customer.delivery_addresses.should_not be_include(unrelated_address)
      post 'delivery_complete', :id => unrelated_address.id
      response.should_not be_success
      flash[:error].should be_nil
      flash[:notice].should be_nil
    end

    it "更新失敗" do
      customer = customers(:have_delivary_address)
      session[:customer_id] = customer.id
      old_address = customer.delivery_addresses[0]
      new_address = delivery_addresses :unvalid_address
      post 'delivery_complete', :id => old_address.id, :delivery_address => new_address.attributes
      response.should redirect_to(:action => 'delivery')
    end

  end

  describe "GET 'delivery_destroy'" do
    fixtures :delivery_addresses
    before do
      @customer = customers(:have_delivary_address)
      session[:customer_id] = @customer.id
      delivery_address = DeliveryAddress.new(delivery_addresses(:optional_address3).attributes)
      delivery_address.customer_id = customers(:have_delivary_address).id
      delivery_address.save!
      @deleted_id = delivery_address.id
    end
    it "should be successful" do
      customer = customers(:have_delivary_address)
      session[:customer_id] = customer.id
      deleted_id = @deleted_id
      get 'delivery_destroy', :id => deleted_id
      response.should redirect_to(:action => 'delivery')
      DeliveryAddress.find(:first, :conditions => ['id=?', deleted_id]).should be_nil
    end

    it "should be successful and backurl" do
      customer = customers(:have_delivary_address)
      session[:customer_id] = customer.id
      deleted_id = @deleted_id
      backurl = "/testurl" 
      get 'delivery_destroy', :id => deleted_id, :backurl => backurl
      response.should redirect_to(backurl)
      DeliveryAddress.find(:first, :conditions => ['id=?', deleted_id]).should be_nil
    end

    it "ユーザと無関係な送付先は削除できない" do
      customer = customers(:have_delivary_address)
      session[:customer_id] = customer.id
      unrelated_address = delivery_addresses(:valid_address)
      customer.delivery_addresses.should_not be_include(unrelated_address)
      get 'delivery_destroy', :id => unrelated_address.id
      response.should_not be_success
      DeliveryAddress.find(unrelated_address.id).should_not be_nil
    end
  end

  describe "GET 'activate'" do
    it "本登録する" do
      customer = customers :kari
      get 'activate', :activation_key => customer.activation_key
      assigns[:customer].should_not be_nil
      assigns[:customer].id.should == customer.id
    end

    it "アクティベーションキーが違う" do
      customer = customers :kari
      get 'activate', :key => customer.activation_key.succ
      assigns[:customer].should be_nil
      session[:customer_id].should be_nil
    end
  end

  describe "GET 'withdraw'" do
    before do
      @customer = customers(:valid_signup)
      session[:customer_id] = @customer.id
    end

    it "should be successful" do
      get 'withdraw'
      response.should be_success
    end
  end

  describe "GET 'withdraw_confirm'" do
    before do
      @customer = customers(:valid_signup)
      session[:customer_id] = @customer.id
    end

    it "should be successful" do
      get 'withdraw_confirm'
      response.should be_success
    end
  end

  describe "POST 'withdraw_complete'" do
    before do
      @customer = customers(:valid_signup)
      session[:customer_id] = @customer.id
    end

    it "should be successful" do
      post 'withdraw_complete'
      response.should be_success
    end

    it "セッションから消す" do
      post 'withdraw_complete'
      response.should be_success
      session[:customer_id].should be_nil
      @customer = Customer.find(@customer.id)
      @customer.activate.should == Customer::TEISHI
    end
  end

  describe "GET 'reminder'" do
    it "should be successful" do
      get 'reminder'
      response.should redirect_to(:action => :salvage)
    end
  end

  it "メールアドレスが入力されていない場合" do
    post 'login'
    response.should render_template("accounts/login.html.erb")
  end

  it "メールアドレスが入力されていない場合" do
    customer = { "email"=>"" }
    post 'login', :customer => customer
    response.should render_template("accounts/login.html.erb")
  end

  it "パスワードが入力されていない場合" do
    customer = { "email"=>"hoge4@hoge.com", "password"=>"" }
    post 'login', :customer => customer
    response.should render_template("accounts/login.html.erb")
  end

  it "登録されていないメールアドレスを入力した場合" do
    customer = { "email"=>"hoge999@hoge.com", "password"=>"hoge" }
    post 'login', :customer => customer
    response.should render_template("accounts/login.html.erb")
  end

  it "パスワードが間違っている場合" do
    customer = { "email"=>"hoge6@hoge.com", "password"=>"invalid" }
    post 'login', :customer => customer
    response.should render_template("accounts/login.html.erb")
  end

  it "パスワードが合っている場合" do
    customer = { "email"=>"hoge6@hoge.com", "password"=>"hogehoge" }
    session[:return_to] = {"controller"=>'accounts', "action"=>'edit'}
    post 'login', :customer => customer
    response.should redirect_to(:controller => 'accounts', :action => 'edit')
    session_customer = Customer.find(session[:customer_id])
    session_customer.email.should == 'hoge6@hoge.com'
    session_customer.correct_password?('hogehoge').should be_true
    session[:return_to].should be_nil
  end

  it "パスワードが合っている場合(dir_nameが正しい時)" do
    campaign = campaigns(:open_campaign)
    customer = { "email"=>"hoge6@hoge.com", "password"=>"hogehoge" }
    session[:return_to] = {"controller"=>'campaigns', "action"=>'show', "dir_name" => campaign.dir_name}
    post 'login', :customer => customer
    response.should redirect_to("campaigns/" + campaign.dir_name)
    session_customer = Customer.find(session[:customer_id])
    session_customer.email.should == 'hoge6@hoge.com'
    session_customer.correct_password?('hogehoge').should be_true
    session[:return_to].should be_nil
  end

  it "return_to が無い場合" do
    customer = { "email"=>"hoge6@hoge.com", "password"=>"hogehoge" }
    session[:return_to] = nil
    post 'login', :customer => customer
    response.should redirect_to('/')
    session_customer = Customer.find(session[:customer_id])
    session_customer.email.should == 'hoge6@hoge.com'
    session_customer.correct_password?('hogehoge').should be_true
  end

#  it "端末の種類が登録時と違うとログインできない" do
#    request.user_agent = 'Amaya/10.0'
#    customer = { "email"=>"user@docomo.ne.jp", "password"=>"docomo" }
#    post 'login', :customer => customer
#    response.should_not be_redirect
#  end
#
#  it "端末の種類が登録時と同じだとログインできる" do
#    request.user_agent = 'DoCoMo/2.0 SH903i(c100;TB;W24H16)'
#    customer = { "email"=>"user@docomo.ne.jp", "password"=>"docomo" }
#    post 'login', :customer => customer
#    flash[:error].should be_nil
#    response.should be_redirect
#  end

  it "端末の種類が登録時と違っていてもログインできる" do
    request.user_agent = 'Amaya/10.0'
    customer = { "email"=>"user@docomo.ne.jp", "password"=>"docomo" }
    post 'login', :customer => customer
    flash[:error].should be_nil
    response.should be_redirect
  end


  it "ログイン前の買い物を取り込む" do
    carts = [carts(:cart_can_incriment)]
    session[:carts] = carts.map(&:attributes)
    customer = customers(:product_buyer)
    post 'login', :customer => {:email => customer.email, :password => 'buyer'}
    flash[:error].should be_nil
    customer = Customer.find(customer.id) # refresh
    customer.carts.zip(carts).each do | actual, expected |
      actual.product_style_id.should == expected.product_style_id
      actual.quantity.should == expected.quantity
    end
  end

  it "ログイン前に買い物していなければそのまま" do
    session[:carts] = nil
    customer = customers(:product_buyer)
    carts = customer.carts
    post 'login', :customer => {:email => customer.email, :password => 'buyer'}
    flash[:error].should be_nil
    customer = Customer.find(customer.id) # refresh
    customer.carts.should == carts
  end

  it "規約がロードされることを確認" do
    get 'kiyaku'
    assigns[:kiyakus].should_not be_nil
    assigns[:kiyakus].size.should == 3
    assigns[:kiyakus][0].should == kiyakus(:kiyaku1)
    assigns[:kiyakus][1].should == kiyakus(:kiyaku2)
    assigns[:kiyakus][2].should == kiyakus(:kiyaku3)
  end
end

