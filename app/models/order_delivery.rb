# -*- coding: utf-8 -*-
# 発送
class OrderDelivery < ActiveRecord::Base

  acts_as_paranoid
  belongs_to :order
  belongs_to :prefecture
  belongs_to :deliv_pref, :class_name => 'Prefecture'
  belongs_to :occupation
  belongs_to :delivery_trader
  belongs_to :delivery_time
  has_many :order_details, :order => 'position'
  has_many :product_order_units
  belongs_to :payment
  has_many :recalls
  has_many :delivery_tickets

  attr_accessor :target_columns

  YOYAKU_UKETSUKE, JUTYUU_TOIAWASE, JUTYUU, CANCEL, HASSOU_TEHAIZUMI, HASSOU_TYUU, HAITATU_KANRYO, HAITATU_CANCEL = 1, 2, 3, 4, 5, 6, 7, 8
  STATUS_NAMES = { YOYAKU_UKETSUKE => "予約受付済み", JUTYUU_TOIAWASE => "受注（メーカー問合わせ中）", JUTYUU => "受注",
                   CANCEL => "キャンセル", HASSOU_TEHAIZUMI => "発送手配済み", HASSOU_TYUU => "発送中", HAITATU_KANRYO => "配達完了",
                   HAITATU_CANCEL => "配達取り消し" }

  FRONT_STATUS_NAMES = STATUS_NAMES.merge({JUTYUU_TOIAWASE =>STATUS_NAMES[JUTYUU]})

  DEFAULT_INCLUDE =  [:order, :order_details]

  def self.find_sum conditions=nil
    select = <<-EOS
      sum(subtotal) as subtotal,
      sum(discount) as discount,
      sum(deliv_fee) as deliv_fee,
      sum(charge) as charge,
      sum(use_point) as use_point
    EOS
    joins = <<-EOS
      join orders on orders.id = order_deliveries.order_id
    EOS
    record = find(:first, :select => select, :conditions => conditions, :joins => joins)
    record.calculate_total! [:total, :payment_total] # subtotal 以外再計算
    record
  end

  def status_view
    STATUS_NAMES[status]
  end

  # フロントページ用(ユーザ向け)
  def front_status_view
    FRONT_STATUS_NAMES[status]
  end

  def self.status_options include_blank=false
    a = STATUS_NAMES.sort_by {|_,value| value}.map {|key,value| [value,key]}
    a.unshift(['', nil]) if include_blank
  end

  def customer_id
    order.customer_id
  end

  # 受注金額
  def proceeds
    total.to_i - charge.to_i
  end

  # 合計を再計算する
  def calculate_total! fields=[:subtotal, :total, :payment_total]
    self.subtotal = get_subtotal() if fields.include? :subtotal
    self.total = subtotal.to_i - discount.to_i + deliv_fee.to_i + charge.to_i if fields.include? :total
    self.payment_total = total.to_i - use_point.to_i  if fields.include? :payment_total
  end

  def before_save
    #calculate_charge!
    #calculate_total!
    update_commit_date!
    update_shipped_at!
    update_delivery_completed_at!
  end

  validates_presence_of :deliv_family_name, :deliv_first_name,
                        :deliv_family_name_kana, :deliv_first_name_kana,
                        :deliv_tel01, :deliv_tel02, :deliv_tel03,
                        :deliv_zipcode01, :deliv_zipcode02,
                        :deliv_pref_id,
                        :deliv_address_city, :deliv_address_detail,
                        :payment_id

  validates_associated :payment

  validates_numericality_of :deliv_tel01, :deliv_tel02, :deliv_tel03,
                            :deliv_zipcode01, :deliv_zipcode02

  validates_length_of :message, :maximum=>3000, :allow_blank => true
  validates_length_of :note, :maximum=>200, :allow_blank => true

  validates_format_of :family_name_kana, :first_name_kana, :deliv_family_name_kana, :deliv_first_name_kana,
                      :with => System::KATAKANA_PATTERN, :allow_blank => true,
                      :message => 'はカタカナで入力してください'

  def validate
    super
    # FAX どれかが入力されている時だけ検証
    if not [deliv_fax01, deliv_fax02, deliv_fax03].all?(&:blank?)
      fax_items = %w(deliv_fax01 deliv_fax02 deliv_fax03)
      errors.add_on_blank fax_items, "が入力されていません"
      fax_items.each do | name |
        errors.add name, "は数字で入力してください" if send(name) =~ /\D/
      end
    end
  end

  #顧客基本情報設定
  def set_customer(customer)
    self.family_name = customer.family_name
    self.first_name = customer.first_name
    self.family_name_kana = customer.family_name_kana
    self.first_name_kana = customer.first_name_kana
    self.email = customer.email
    self.tel01 = customer.tel01
    self.tel02 = customer.tel02
    self.tel03 = customer.tel03
    self.fax01 = customer.fax01
    self.fax02 = customer.fax02
    self.fax03 = customer.fax03
    self.zipcode01 = customer.zipcode01
    self.zipcode02 = customer.zipcode02
    self.prefecture_id = customer.prefecture_id
    self.address_city = customer.address_city
    self.address_detail = customer.address_detail
    self.sex = customer.sex
    self.birthday = customer.birthday
    self.occupation_id = customer.occupation_id
  end

  #住所情報を配送先に設定
  def set_delivery_address(delivery_address)
    self.deliv_family_name = delivery_address.family_name
    self.deliv_first_name = delivery_address.first_name
    self.deliv_family_name_kana = delivery_address.family_name_kana
    self.deliv_first_name_kana = delivery_address.first_name_kana
    self.deliv_tel01 = delivery_address.tel01
    self.deliv_tel02 = delivery_address.tel02
    self.deliv_tel03 = delivery_address.tel03
    self.deliv_zipcode01 = delivery_address.zipcode01
    self.deliv_zipcode02 = delivery_address.zipcode02
    self.deliv_pref_id = delivery_address.prefecture_id
    self.deliv_address_city = delivery_address.address_city
    self.deliv_address_detail = delivery_address.address_detail
  end

  #カート内容を注文詳細に設定
  def details_build_from_carts(carts)
    carts.each do | cart |
      d = order_details.build
      d.set_cart(cart)
    end
    order_details
  end

  # 手数料、送料を更新する
  def calculate_charge!
    self.charge = payment && payment.fee
    self.deliv_fee = get_delivery_fee()
  end

  def payment_name
    payment && payment.name
  end

  def delivery_time_name
    delivery_time ? delivery_time.name : '指定なし'
  end

  def order_code
    order && order.code
  end

  def prefecture_name
    prefecture && prefecture.name
  end

  def occupation_name
    occupation && occupation.name
  end

  def sex_name
    System::SEX_NAMES[sex]
  end

  def deliv_pref_name
    deliv_pref && deliv_pref.name
  end

  def delivery_trader_name
    delivery_trader && delivery_trader.name
  end

  def received_at
    order && order.received_at
  end

  def delivery_ticket_codes(delimiter="/")
    delivery_tickets.map(&:code).join(delimiter)
  end

  def ticket_code
    delivery_tickets[0] && delivery_tickets[0].code
  end

  # 送料を計算する
  def get_delivery_fee
    # 送料無料条件以上に買っていれば無料
    free_delivery_rule = System.find(:first).free_delivery_rule
    if free_delivery_rule && get_subtotal() >= free_delivery_rule
      return 0
    end
    # 送料無料の商品があれば無料
    order_details.any? do |detail|
      detail.ps.product.free_delivery?
    end and return 0
    # 離島だったら離島の価格（郵便番号が入力間違ってzipに存在しない時も離島として）
    # 都道府県ID = nil として処理する
    prefecture_id = deliv_pref_id
    conds = [<<-SQL, self.attributes.symbolize_keys]
      zipcode01=:deliv_zipcode01 and
      zipcode02=:deliv_zipcode02
    SQL
    zip = Zip.find(:first, :conditions => conds)
    if !zip or zip.isolation_type == 1
      prefecture_id = nil
    end
    # 都道府県別の送料を求める
    # 都道府県ID = nilの場合、離島であることとして
    delivery_fee = DeliveryFee.find_by_delivery_trader_id_and_prefecture_id(delivery_trader_id, prefecture_id)
    delivery_fee && delivery_fee.price
  end

  # 支払い方法の候補
  def payment_candidates(price)
    payments = Payment.find_for_price(price)
    payments
  end

  #発送伝票番号の登録
  def update_ticket(ticket_code)
    if status >= HASSOU_TYUU && !ticket_code.blank?
      ticket = delivery_tickets[0] || DeliveryTicket.new({:order_delivery_id => id})
      ticket.code = ticket_code
      ticket.save!
    end
  end

  class << self
    def update_by_csv(filepath, retailer_id)
      line = 0
      update_line = 0
      OrderDelivery.transaction do
        CSV.foreach(filepath, encoding: Encoding::Shift_JIS) do |row|
          if line != 0
            record = OrderDelivery.find_by_order_id(row[0].to_i)
            return [line-1, update_line, false] if record.order.retailer_id != retailer_id
            params = get_params(Iconv.conv('UTF-8', 'cp932', row[49]), row[47], row[48])
            if record
              if record.update_attributes(params)
                #発送伝票番号の登録
                record.update_ticket(row[54])
              else
                return [line-1, update_line, false]
              end
            else
              return [line-1, update_line, false]
            end
            update_line = update_line + 1
          end
          line = line + 1
        end
      end
      [line - 1, update_line, true]
    end

    private

    def get_params(status, shipped_at, delivery_completed_at)
      status_id = STATUS_NAMES.invert[status]
      unless status_id == nil
        if shipped_at.blank?
          if HASSOU_TYUU <= status_id
            shipped_at = DateTime.now
          else
            shipped_at = 'null'
          end
        end
        if delivery_completed_at.blank?
          if HAITATU_KANRYO <= status_id
            delivery_completed_at = DateTime.now
          else
            delivery_completed_at = 'null'
          end
        end
      end
      return {:status=>status_id, :shipped_at=>shipped_at, :delivery_completed_at=>delivery_completed_at}
    end
  end

  def self.csv_columns_name
    [
      :order_id,
      :order_code,
      :family_name,
      :first_name,
      :family_name_kana,
      :first_name_kana,
      :zipcode01,
      :zipcode02,
      :prefecture_name,
      :address_city,
      :address_detail,
      :tel01,
      :tel02,
      :tel03,
      :fax01,
      :fax02,
      :fax03,
      :email,
      :occupation_name,
      :sex_name,
      :birthday,
      :subtotal,
      :deliv_fee,
      :charge,
      :use_point,
      :add_point,
      :total,
      :payment_name,
      :payment_total,
      :message,
      :deliv_family_name,
      :deliv_first_name,
      :deliv_family_name_kana,
      :deliv_first_name_kana,
      :deliv_pref_name,
      :deliv_zipcode01,
      :deliv_zipcode02,
      :deliv_address_city,
      :deliv_address_detail,
      :deliv_tel01,
      :deliv_tel02,
      :deliv_tel03,
      :deliv_fax01,
      :deliv_fax02,
      :deliv_fax03,
      :delivery_trader_name,
      :delivery_time_name,
      :shipped_at,
      :delivery_completed_at,
      :status_view,
      :commit_date,
      :created_at,
      :updated_at,
      :note,
      :ticket_code
    ]
  end

  def self.set_field_names
    {
      :order_id => "注文ID",
      :order_code => "受注番号",
      :family_name => "姓",
      :first_name => "名",
      :family_name_kana => "姓(セイ)",
      :first_name_kana => "名(メイ)",
      :zipcode01 => "郵便番号(前半)",
      :zipcode02 => "郵便番号(後半)",
      :prefecture_name => "都道府県",
      :address_city => "住所(市区町村)",
      :address_detail => "住所(詳細)",
      :tel01 => "電話番号01",
      :tel02 => "電話番号02",
      :tel03 => "電話番号03",
      :fax01 => "FAX番号01",
      :fax02 => "FAX番号02",
      :fax03 => "FAX番号03",
      :email => "メールアドレス",
      :occupation_name => "職業",
      :sex_name => "性別",
      :birthday => "誕生日",
      :subtotal => "小計",
      :deliv_fee => "送料",
      :charge => "手数料",
      :use_point => "使用ポイント",
      :add_pont => "追加ポイント",
      :total => "合計",
      :payment_name => "支払方法",
      :payment_total => "支払合計",
      :message => "メッセージ",
      :deliv_family_name => "配送先 姓",
      :deliv_first_name => "配送先 名",
      :deliv_family_name_kana => "配送先 姓(カナ)",
      :deliv_first_name_kana => "配送先 名(カナ)",
      :deliv_pref_name => "配送先都道府県",
      :deliv_zipcode01 => "発送先郵便番号(前半)",
      :deliv_zipcode02 => "配送先郵便番号(後半)",
      :deliv_address_city => "配送先住所(市区町村)",
      :deliv_address_detail => "配送先住所(詳細)",
      :deliv_tel01 => "配送先電話番号01",
      :deliv_tel02 => "配送先電話番号02",
      :deliv_tel03 => "配送先電話番号03",
      :deliv_fax01 => "配送先FAX番号01",
      :deliv_fax02 => "配送先FAX番号02",
      :deliv_fax03 => "配送先FAX番号03",
      :delivery_trader_name => "配送業者",
      :delivery_time_name => "発送時間",
      :shipped_at => "発送日",
      :delivery_completed_at => "配達完了",
      :status_view => "ステータス",
      :commit_date => "受注日",
      :created_at => "登録日",
      :updated_at => "更新日",
      :note => "SHOPメモ",
      :ticket_code => "発送伝票番号"
    }
  end

  private

  # ステータスを発送中、配達完了に変更した場合、
  # その時点の日時を commit_date に入れる。
  # 逆の場合は commit_date をクリアする。
  # 例、
  # 受注から配送中へ変更する時、更新
  # 受注から配送完了へ変更する時、更新
  # 配送中から配送完了へ変更する時、そのまま
  # 配送中から受注へ変更する時、クリア
  # 配送完了から受注へ変更する時、クリア
  def update_commit_date!
    commited_statuses = [HASSOU_TYUU, HAITATU_KANRYO]
    status_changed? or return
    before, after = status_change
    if !commited_statuses.include?(before) && commited_statuses.include?(after)
      # 発送中に変わった
      self.commit_date = DateTime.now
    elsif commited_statuses.include?(before) && !commited_statuses.include?(after)
      # 発送中から変わった
      self.commit_date = nil
    end
  end

  def update_shipped_at!
    shipped_statuses = [HASSOU_TYUU, HAITATU_KANRYO]
    status_changed? or return
    before, after = status_change
    if !shipped_statuses.include?(before) && shipped_statuses.include?(after)
      self.shipped_at = DateTime.now if self.shipped_at.blank?
    elsif shipped_statuses.include?(before) && !shipped_statuses.include?(after)
      self.shipped_at = nil if self.shipped_at.blank?
    end
  end

  def update_delivery_completed_at!
    completed_statuses = [HAITATU_KANRYO]
    status_changed? or return
    before, after = status_change
    if !completed_statuses.include?(before) && completed_statuses.include?(after)
      self.delivery_completed_at = DateTime.now if self.delivery_completed_at.blank?
    elsif completed_statuses.include?(before) && !completed_statuses.include?(after)
      self.delivery_completed_at = nil if self.delivery_completed_at.blank?
    end
  end

  def get_subtotal
    order_details.map(&:subtotal).map(&:to_i).sum
  end

  def to_db_date(s)
    if s
      "'" + s + "'"
    else
      "null"
    end
  end

end
