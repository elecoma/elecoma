require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrderDelivery do
  fixtures :orders, :order_details,:order_deliveries, :prefectures,:payments,:delivery_times,:delivery_traders,:occupations,:delivery_tickets  
  before(:each) do
    #会員
    @order_delivery = order_deliveries(:customer_buy_two)
    #非会員
    @order_delivery2 = order_deliveries(:not_customer_buy_one)
  end
  
  describe "validateチェック" do
    it "データが正しい" do
      @order_delivery.should be_valid
    end
    it "配送先姓" do
      #必須チェック
      @order_delivery.deliv_family_name = nil
      @order_delivery.should_not be_valid
    end
    it "配送先名" do
      #必須チェック
      @order_delivery.deliv_first_name = nil
      @order_delivery.should_not be_valid
    end
    it "配送先姓(カナ)" do
      #必須チェック
      @order_delivery.deliv_family_name_kana = nil
      @order_delivery.should_not be_valid
      #カタカナチェック
      @order_delivery.deliv_family_name_kana = "aaa"
      @order_delivery.should_not be_valid
    end
    it "配送先名(カナ)" do
      #必須チェック
      @order_delivery.deliv_first_name_kana = nil
      @order_delivery.should_not be_valid
      #カタカナチェック
      @order_delivery.deliv_first_name_kana = "aaa"
      @order_delivery.should_not be_valid
    end
    it "配送先電話番号1" do
      #必須
      @order_delivery.deliv_tel01 = nil
      @order_delivery.should_not be_valid
      #数字
      @order_delivery.deliv_tel01 = "aaa"
      @order_delivery.should_not be_valid
    end
    it "配送先電話番号2" do
      #必須
      @order_delivery.deliv_tel02 = nil
      @order_delivery.should_not be_valid
      #数字
      @order_delivery.deliv_tel02 = "aaa"
      @order_delivery.should_not be_valid
    end      
    it "配送先電話番号3" do
      #必須
      @order_delivery.deliv_tel03 = nil
      @order_delivery.should_not be_valid
      #数字
      @order_delivery.deliv_tel03 = "aaa"
      @order_delivery.should_not be_valid
    end
    it "配送先郵便番号（前半）" do
      #必須
      @order_delivery.deliv_zipcode01 = nil
      @order_delivery.should_not be_valid
      #数字
      @order_delivery.deliv_zipcode01 = "aaa"
      @order_delivery.should_not be_valid
    end
    it "配送先郵便番号（後半）" do
      #必須
      @order_delivery.deliv_zipcode02 = nil
      @order_delivery.should_not be_valid
      #数字
      @order_delivery.deliv_zipcode02 = "aaa"
      @order_delivery.should_not be_valid
    end
    it "配送先都道府県ID" do
      #必須
      @order_delivery.deliv_pref_id = nil
      @order_delivery.should_not be_valid
    end
    it "配送先住所（市区町村）" do
      #必須
      @order_delivery.deliv_address_city = nil
      @order_delivery.should_not be_valid
    end
    it "配送先住所（詳細）" do
      #必須
      @order_delivery.deliv_address_detail = nil
      @order_delivery.should_not be_valid
    end
    it "支払方法ID" do
      #必須
      @order_delivery.payment_id = nil
      @order_delivery.should_not be_valid
    end
    it "その他お問い合わせ" do
      #文字数（3000以下）
      @order_delivery.message = "あ" * 3000
      @order_delivery.should be_valid
      @order_delivery.message = "a" * 3001
      @order_delivery.should_not be_valid
    end
    it "SHOPメモ" do
      #文字数（200以下）
      @order_delivery.note = "あ" * 200
      @order_delivery.should be_valid
      @order_delivery.note = "a" * 201
      @order_delivery.should_not be_valid
    end
    it "FAX番号" do
      #数字
      @order_delivery.deliv_fax01 = 'abc'
      @order_delivery.deliv_fax02 = 'defg'
      @order_delivery.deliv_fax03 = 'hijk'
      @order_delivery.should have(1).errors_on(:deliv_fax01)
      @order_delivery.should have(1).errors_on(:deliv_fax02)
      @order_delivery.should have(1).errors_on(:deliv_fax03)
      #入力の場合、3か所とも
      @order_delivery.deliv_fax01 = nil
      @order_delivery.deliv_fax02 = '1111'
      @order_delivery.deliv_fax03 = '2222'
      @order_delivery.should_not be_valid
    end
  end
  
  describe "表示系" do
    it "注文ステータス" do
      #管理側
      @order_delivery.status = OrderDelivery::CANCEL
      @order_delivery.status_view.should == OrderDelivery::STATUS_NAMES[OrderDelivery::CANCEL]
      #受注（メーカー問合わせ中）
      @order_delivery.status = OrderDelivery::JUTYUU
      @order_delivery.status_view.should == OrderDelivery::STATUS_NAMES[OrderDelivery::JUTYUU]
      #フロント側
      #通常
      @order_delivery.status = OrderDelivery::HASSOU_TEHAIZUMI
      @order_delivery.front_status_view.should == OrderDelivery::FRONT_STATUS_NAMES[OrderDelivery::HASSOU_TEHAIZUMI]
      #受注（メーカー問合わせ中）の場合「受注」と表示
      @order_delivery.status = OrderDelivery::JUTYUU_TOIAWASE
      @order_delivery.front_status_view.should == OrderDelivery::FRONT_STATUS_NAMES[OrderDelivery::JUTYUU]
    end
    it "支払方法" do
      od = OrderDelivery.new(:payment_id => payments(:food).id)
      od.payment_name.should == payments(:food).name
    end
    it "配送時間" do
      #配送時間が選択された場合
      od = OrderDelivery.new(:delivery_time_id => delivery_times(:morning).id)
      od.delivery_time_name.should == delivery_times(:morning).name
      #配送時間が選択されない場合
      od = OrderDelivery.new
      od.delivery_time_name.should == "指定なし"
    end
    it "注文番号" do
      @order_delivery.order_code.should == orders(:customer_buy_two).code
    end
    it "顧客住所（県）" do
      od = OrderDelivery.new(:prefecture_id => prefectures(:prefecture_00013).id)
      od.prefecture_name.should == prefectures(:prefecture_00013).name
    end
    it "配送先住所（県）" do
      od = OrderDelivery.new(:deliv_pref_id => prefectures(:prefecture_00047).id)
      od.deliv_pref_name.should == prefectures(:prefecture_00047).name      
    end
    it "職業" do
      #職業が選択された場合
      od = OrderDelivery.new(:occupation_id => occupations(:government_worker).id)
      od.occupation_name.should == occupations(:government_worker).name
      #職業が選択選択されない場合
      od = OrderDelivery.new
      od.occupation_name.should be_nil
    end
    it "性別" do
      od = OrderDelivery.new(:sex => System::MALE)
      od.sex_name.should == System::SEX_NAMES[System::MALE]
      od = OrderDelivery.new(:sex => System::FEMALE)
      od.sex_name.should == System::SEX_NAMES[System::FEMALE]
    end
    it "配送業者名" do
      od = OrderDelivery.new(:delivery_trader_id => delivery_traders(:witch))
      od.delivery_trader_name.should == delivery_traders(:witch).name
    end
    it "受注日" do
      @order_delivery.received_at.should == orders(:customer_buy_two).received_at
    end
    it "すべての伝票番号" do
      #伝票番号がある場合
      @order_delivery.delivery_ticket_codes.should == delivery_tickets(:customer_buy_two_1).code+'/'+delivery_tickets(:customer_buy_two_2).code
      #伝票番号がない場合
      @order_delivery2.delivery_ticket_codes.should == ""
    end
    it "一番上の伝票番号" do
      #伝票番号がある場合
      @order_delivery.ticket_code.should == delivery_tickets(:customer_buy_two_1).code
      #伝票番号がない場合
      @order_delivery2.ticket_code.should be_nil
    end
  end

  describe "金額計算系" do
    fixtures :delivery_fees,:product_statuses,:zips,:systems,:products,:product_styles,:statuses
    before(:each) do
      @details = [order_details(:customer_buy_two_1), order_details(:customer_buy_two_2)]
    end
    it "受注金額" do
      @order_delivery.proceeds.should == @order_delivery.total - @order_delivery.charge
      
      @order_delivery.total = 1000
      @order_delivery.charge = 100
      @order_delivery.proceeds.should == 900
    end
    it "合計を再計算する" do
      #元データ
      @order_delivery.subtotal.should == @details[0].subtotal + @details[1].subtotal
      @order_delivery.total.should == @order_delivery.subtotal - @order_delivery.discount.to_i + @order_delivery.deliv_fee.to_i + @order_delivery.charge.to_i
      @order_delivery.payment_total.should == @order_delivery.total.to_i - @order_delivery.use_point.to_i

      #説明：下記のように設定して、再計算
      #order_detail
      #detail1: price = 1000; tax = 50; quantity = 1
      #detail2: price = 1000; tax = 50; quantity = 2
      #discount = 300
      #deliv_fee = 300
      #charge = 200
      #use_point = 150

      #再計算後の期待結果：
      #subtotal = 3150
      #total = subtotal - discount + deliv_fee + charge = 3350
      #payment_total = total - point = 3200
      
      od_subtotal = 0
      @order_delivery.order_details.each_with_index do |detail,i|
        @order_delivery.order_details[i] = OrderDetail.new(:price =>1000,:tax_price=>50,:quantity => (i+1))
        od_subtotal += @order_delivery.order_details[i].subtotal
      end
      @order_delivery.discount = 300
      @order_delivery.deliv_fee = 300
      @order_delivery.charge = 200
      @order_delivery.use_point = 150
      #再計算
      @order_delivery.calculate_total!
      #結果
      #小計
      @order_delivery.subtotal.should == od_subtotal #3150
      #総計 = 小計-割引＋配送料+費用
      @order_delivery.total.should == 3350
      #支払金額=総計-使用ポイント
      @order_delivery.payment_total.should == 3200     
    end
    it "手数料、送料を更新する" do
      #元データ
      @order_delivery.charge.should == payments(:cash).fee
      
      #手数料は支払い方法により変わるので、
      #支払方法を変更してテスト
      #送料は別途「送料を計算する」でテストする
      @order_delivery.payment_id = payments(:from1million).id
      @order_delivery.calculate_charge!
      @order_delivery.charge.should == payments(:from1million).fee
    end
    it "送料を計算する" do
      #systemテーブルに設定した送料無料の条件は2500
      #送料有料製品購入で金額は送料無料条件以上に買っていれば無料
      order_delivery = order_deliveries(:customer_buy_one_with_option_deliv)
      order_delivery.get_delivery_fee.should == 0
      #送料無料条件以下に買っていれば地方別送料を請求(送料無料製品なし)
      #systemテーブルに設定した送料無料の条件を50000にアップ
      System.update_all(['free_delivery_rule=?',50000])
      order_delivery.get_delivery_fee.should == delivery_fees(:delivery_fee_13).price
      #金額が無料条件に達していないが送料無料の商品があれば無料
      order_delivery = order_deliveries(:customer_buy_two_with_point)
      order_delivery.get_delivery_fee.should == 0
      #離島
      order_delivery = order_deliveries(:not_customer_ritou)
      order_delivery.get_delivery_fee.should == delivery_fees(:delivery_fee_48).price
    end
    it 'find_sum' do
      conditions = ['order_deliveries.id < ?', 100]
      records = OrderDelivery.find(:all, :conditions => conditions,:joins =>"join orders on orders.id = order_deliveries.order_id")
  
      expected_subtotal = 0
      expected_discount = 0
      expected_deliv_fee = 0
      expected_charge = 0
      expected_use_point = 0
      expected = records.each do | record |
        expected_subtotal += record.subtotal.to_i
        expected_discount += record.discount.to_i
        expected_deliv_fee += record.deliv_fee.to_i
        expected_charge += record.charge.to_i
        expected_use_point += record.use_point.to_i
      end
      actual = OrderDelivery.find_sum(conditions)
      actual.discount.should == expected_discount
      actual.deliv_fee.should == expected_deliv_fee
      actual.charge.should == expected_charge
      actual.use_point.should == expected_use_point
      actual.subtotal.should == expected_subtotal
    end
  end
  
  describe "その他" do
    fixtures :delivery_addresses,:carts
    it "ステータスによりcommit_date を更新" do
      #配送中に変えた時、commit_dateを現在時間に更新
      @order_delivery.commit_date = nil
      @order_delivery.status = OrderDelivery::HASSOU_TYUU
      @order_delivery.save
      @order_delivery.commit_date.should_not be_nil
      #配送中から配送完了に変えた時、commit_dateをそのまま
      before = @order_delivery.commit_date
      @order_delivery.status = OrderDelivery::HAITATU_KANRYO
      @order_delivery.save
      @order_delivery.commit_date.should == before
      #配送中、配送完了以外の場合、commit_dateがをクリア
      @order_delivery.status = OrderDelivery::JUTYUU
      @order_delivery.save
      @order_delivery.commit_date.should be_nil
      #受注から配送完了へ変えた時、commit_dateを現在時間に更新
      @order_delivery.status = OrderDelivery::HAITATU_KANRYO
      @order_delivery.save
      @order_delivery.commit_date.should_not be_nil
    end
    it "ステータスにより発送日を更新" do
      #配送中に変えた時、shipped_atを現在時間に更新
      @order_delivery.shipped_at = nil
      @order_delivery.status = OrderDelivery::HASSOU_TYUU
      @order_delivery.save
      @order_delivery.shipped_at.should_not be_nil
      #配送中から配送完了に変えた時、shipped_atをそのまま
      before = @order_delivery.shipped_at
      @order_delivery.status = OrderDelivery::HAITATU_KANRYO
      @order_delivery.save
      @order_delivery.shipped_at.should == before
      #配送中、配送完了以外の場合、shipped_atがそのまま
      @order_delivery.status = OrderDelivery::JUTYUU
      @order_delivery.save
      @order_delivery.shipped_at.should == before
      #受注から配送完了へ変えた時、shipped_atを現在時間に更新
      @order_delivery.status = OrderDelivery::HAITATU_KANRYO
      @order_delivery.save
      @order_delivery.shipped_at.should_not be_nil
    end
    it "ステータスにより発送完了日を更新" do
      #配送完了に変えた時、delivery_completed_atを現在時間に更新
      @order_delivery.delivery_completed_at = nil
      @order_delivery.status = OrderDelivery::HAITATU_KANRYO
      @order_delivery.save
      @order_delivery.delivery_completed_at.should_not be_nil
      before = @order_delivery.delivery_completed_at
      #配送完了以外に変えた時、delivery_completed_atがそのまま
      @order_delivery.status = OrderDelivery::HASSOU_TYUU
      @order_delivery.save
      @order_delivery.delivery_completed_at.should == before
    end    
    it "顧客 ID" do
      @order_delivery.customer_id.should == @order_delivery.order.customer_id
      @order_delivery2.customer_id.should == @order_delivery2.order.customer_id
      @order_delivery2.customer_id.should be_nil
    end
    it "支払い方法の候補" do
      @order_delivery.payment_candidates(1000).should == [payments(:cash),payments(:food)]
      @order_delivery.payment_candidates(20000).should == [payments(:cash),payments(:food),payments(:from_million)]
    end
    it "発送伝票番号の登録" do
      #登録前
      @order_delivery2.delivery_tickets.count.should == 0
      #登録(注文ステータスが配送中のみ更新)
      #更新しないケース
      @order_delivery2.update_ticket("20091113001")
      @order_delivery2.delivery_tickets.count.should == 0
      #更新するケース
      @order_delivery2.status = OrderDelivery::HASSOU_TYUU
      @order_delivery2.update_ticket("20091113001")
      #登録後
      @order_delivery2.delivery_tickets.count.should == 1
      DeliveryTicket.find_by_order_delivery_id(@order_delivery2.id).code.should == "20091113001"
      
    end
    it "顧客基本情報設定" do
      od = OrderDelivery.new
      customer = Customer.new(@order_delivery.order.customer.attributes)
      od.set_customer(customer)
      
      od.family_name.should == customer.family_name
      od.first_name.should == customer.first_name
      od.family_name_kana.should == customer.family_name_kana
      od.first_name_kana.should == customer.first_name_kana
      od.email.should == customer.email
      od.tel01.should == customer.tel01
      od.tel02.should == customer.tel02
      od.tel03.should == customer.tel03
      od.fax01.should == customer.fax01
      od.fax02.should == customer.fax02
      od.fax03.should == customer.fax03
      od.zipcode01.should == customer.zipcode01
      od.zipcode02.should == customer.zipcode02
      od.prefecture_id.should == customer.prefecture_id
      od.address_city.should == customer.address_city
      od.address_detail.should == customer.address_detail
      od.sex.should == customer.sex
      od.birthday.should == customer.birthday
      od.occupation_id.should == customer.occupation_id
    end
    it "住所情報を配送先に設定" do
      od = OrderDelivery.new
      delivery_address = DeliveryAddress.new(delivery_addresses(:optional_address_of_customer_33).attributes)
      od.set_delivery_address(delivery_address)
      
      od.deliv_family_name.should == delivery_address.family_name
      od.deliv_first_name.should == delivery_address.first_name
      od.deliv_family_name_kana.should == delivery_address.family_name_kana
      od.deliv_first_name_kana.should == delivery_address.first_name_kana
      od.deliv_tel01.should == delivery_address.tel01
      od.deliv_tel02.should == delivery_address.tel02
      od.deliv_tel03.should == delivery_address.tel03
      od.deliv_zipcode01.should == delivery_address.zipcode01
      od.deliv_zipcode02.should == delivery_address.zipcode02
      od.deliv_pref_id.should == delivery_address.prefecture_id
      od.deliv_address_city.should == delivery_address.address_city
      od.deliv_address_detail.should == delivery_address.address_detail
    end
    it "カート内容を注文詳細に設定" do
      carts = [carts(:valid_cart)]
      od = OrderDelivery.new
      order_details = od.details_build_from_carts(carts)
      carts.each_with_index do |cart,i|
        order_details[i].product_style_id.should == cart.product_style_id
        order_details[i].quantity.should == cart.quantity
        order_details[i].position.should == cart.position
        product_style = cart.product_style
        order_details[i].product_name.should == product_style.product.name
        order_details[i].product_code.should == product_style.code
        order_details[i].product_category_id.should == product_style.product.category_id
        order_details[i].price.should == product_style.sell_price
        order_details[i].style_category_name1.should == product_style.style_category_name1
        order_details[i].style_category_name2.should == product_style.style_category_name2
        order_details[i].style_name1.should == product_style.style_name1
        order_details[i].style_name2.should == product_style.style_name2
        order_details[i].product_id.should == product_style.product.id
        order_details[i].tax_price.should == 0
      end
    end
  end
end
