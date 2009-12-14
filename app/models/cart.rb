class Cart < ActiveRecord::Base

  acts_as_paranoid
  belongs_to :customer
  belongs_to :product_style

  delegate_to :product_style, :product
  delegate_to :product_style, :product, :id, :as => :product_id
  delegate_to :product_style, :product, :name, :as => :product_name
  delegate_to :product_style, :sell_price, :as => :price
  delegate_to :product_style, :style_category1, :name, :as => :classcategory_name1
  delegate_to :product_style, :style_category2, :name, :as => :classcategory_name2

  def subtotal
    if product_style
      product_style.including_tax_sell_price * quantity.to_i
    else
      nil
    end
  end

  def validate
    if customer && customer.black
      errors.add_to_base('申し訳ありませんが販売を終了させて頂きました。')
    end
    if quantity == 0
      errors.add :quantity, 'が 0 です。削除してください。'
    end
    unless product_style
      errors.add :product_style, 'がありません。削除してください。'
    else
      ## product_style が必要な検証
      # 受注可能数以内か
      if quantity > product_style.available?(quantity)
        errors.add_to_base('購入可能な数量を超過しています')
      end
      # キャンペーンが生きているか
      if product_style.product && campaign = product_style.product.campaign
        unless campaign.check_term
          errors.add_to_base('キャンペーン期間外です。')
        end
      end
      product = product_style.product
      unless product.permit
        errors.add_to_base('申し訳ありませんが販売を終了させて頂きました。')
      end
      unless product.in_sale_term?
        errors.add_to_base('申し訳ありませんが販売を終了させて頂きました。')
      end
    end
  end
end
