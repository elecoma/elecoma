# -*- coding: utf-8 -*-
class ProductStyle < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :product
  belongs_to :style_category1, 
             :class_name => "StyleCategory",
             :foreign_key => "style_category_id1"
  belongs_to :style_category2, 
             :class_name => "StyleCategory",
             :foreign_key => "style_category_id2"
  has_many :purchase_details

  belongs_to :style1, 
             :class_name => "Style",
             :foreign_key => "style_id1"
  belongs_to :style2, 
             :class_name => "Style",
             :foreign_key => "style_id2"
  has_many :stock_histories
             
  validates_format_of :code, :with => /^[a-zA-Z0-9]*$/
  validates_format_of :manufacturer_id, :with => /^[a-zA-Z0-9]*$/, :allow_blank=>true

=begin rdoc
  * INFO

    parametors:
      :size => Fixnum[必須]

    return:
      引数 [size] が購入可能な個数であれば、 [size] を返す。
      引数 [size] が購入可能な個数を超過する場合は、 購入可能な最大数 を返す。
=end
  def available?(size)
    #販売可能数で判断
    orderable_count.to_i > 0 ? (check = orderable_count.to_i) : (check = 0)
    limit = [check, size].min
    product.sell_limit ? [limit, product.sell_limit].min : limit
  end

  delegate_to :style_category1, :name, :as => :style_category_name1
  delegate_to :style_category2, :name, :as => :style_category_name2
  delegate_to :style_category1, :style, :name, :as => :style_name1
  delegate_to :style_category2, :style, :name, :as => :style_name2

  # 税込販売額
  def including_tax_sell_price
    sell_price # sell_price は税込み価格
  end

  def validate
    if style_category1.nil? && ! style_category2.nil?
      self.errors.add nil,"規格1が無い状態で規格 2を登録出来ません。"
    end
    if sell_price.to_s.length > 10
      self.errors.add :sell_price, "数値が大き過ぎます。" 
    end
    if sell_price.blank? || sell_price == 0
      self.errors.add :sell_price, "を入力して下さい" 
    end
  end

  # 受注する
  def order(number)
    #販売可能数で判断
    if orderable_count.to_i > 0
      self.orderable_count -= number
      self.actual_count -= number
    else
      raise '在庫不足です。'
    end
  end

  # 規格分類込みの名称
  def full_name(delimiter=' ')
    [product.name, style_category_name1, style_category_name2].inject([]) do | xs, x |
      x.blank? and break xs
      xs << x
    end.join(delimiter)
  end

  def product_name
    product && product.name
  end
  # 規格分類名称
  def style_name(delimiter=' ')
    [style_category_name1, style_category_name2].inject([]) do | xs, x |
      x.blank? and break xs
      xs << x
    end.join(delimiter)
  end
end
