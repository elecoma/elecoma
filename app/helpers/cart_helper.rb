# -*- coding: utf-8 -*-
module CartHelper

  # カートを渡すと、カート内の商品への加算用リンクを生成します。
  def incriment_tag(cart)
    uri = {:controller => 'cart',
           :action => 'inc',
           :id => cart.product_order_unit_id}
    str = request.mobile? ? "増やす" : " ＋ "
    if request.mobile.respond_to?('smartphone?')
	link_to str, url_for(uri), {:class => 'rosy small_button'}
    else
	link_to str, url_for(uri), {:class => 'product_incriment'}
    end
  end

  # カートを渡すと、カート内の商品への減算用リンクを生成します。
  def decriment_tag(cart)
    uri = {:controller => 'cart',
           :action => 'dec',
           :id => cart.product_order_unit_id}
    str = request.mobile? ? "減らす" : " － "
      if request.mobile.respond_to?('smartphone?')
	link_to str, url_for(uri), {:class => 'rosy small_button'}
    else
	link_to str, url_for(uri), {:class => 'product_decriment'}
    end
  end

  # 非会員用お届け先追加のJavaScript
  def optional_address_script
    enable_setting = {
      :parametor => false,
      :style     => {:backgroundColor => '#ffffff'}
    }

    disable_setting = {
      :parametor => true,
      :style     => {:backgroundColor => '#f0f0f0'}
    }
    js = <<"EJS"
      function fnCheckOptionalAddress() {
        if(!$$('.optional_address').first().disabled) {
          fnChangeOptionalAddress('#dddddd');
        } else {
          fnChangeOptionalAddress('');
        }
      }

      function fnChangeOptionalAddress(color) {
      if(color == "") {
        #{update_page do |page|
          page.select('.optional_address').each('disabled') do |element|
            element.disabled = enable_setting[:parametor]
          end
          page.select('.optional_address').each('disabled') do |element|
            element.setStyle enable_setting[:style]
          end
        end}

      } else {

        #{update_page do |page|
          page.select('.optional_address').each('disabled') do |element|
            element.disabled = disable_setting[:parametor]
          end
          page.select('.optional_address').each('disabled') do |element|
            element.setStyle disable_setting[:style]
          end
        end}

      }
    }
EJS

    javascript_tag js
  end

=begin rdoc
  * INFO

    parametors:
      :address => DeliveryAddress[必須]

    return:
      引数として渡された、DeliveryAddressインスタンスが、会員登録情報から生成されたものであれば
      checked="checked"かつ、value="0"となるラジオボタンタグを生成する。
      追加お届け先の場合は、checked="checked"とはならず、valueにはお届け先IDが格納された
      ラジオボタンタグを生成する。

   dependent:
     Customer#basic_address

=end
  def address_button(address)
    parametors = ['address_select']
    parametors << (address.frozen? ? '0' : address.id.to_s)
    parametors << address.frozen?
    radio_button_tag(parametors[0], parametors[1], parametors[2], :class => "radio_btn")
  end

=begin rdoc
  * INFO

    parametors:
      :address => DeliveryAddress[必須]

    return:
      引数として渡された、DeliveryAddressインスタンスが、会員登録情報から生成されたものであれば、
      "会員登録住所"と返し、そうでない場合(追加お届け先である場合)は、"追加登録住所"と返す

    dependent:
      Customer#basic_address

=end
  def address_type_to_s(address)
    h(address.frozen? ? "会員登録住所" : "追加登録住所")
  end

=begin rdoc
  * INFO

    parametors:
      :address => DeliveryAddress[必須]

    return:
      引数として渡された、DeliveryAddressの都道府県名、市区町村、詳細住所を結合して返す

=end
  def address_detail(address)
    zip = '〒'+address.zipcode01 + '-' + address.zipcode02
    addr = [address.prefecture.name, address.address_city, address.address_detail].join(' ')
    add_name = address.family_name + '　' + address.first_name
    res = ''
    res << h(zip)
    res << '<br/>'
    res << h(addr)
    res << '<br/>'
    res << h(add_name)
  end

=begin rdoc
  * INFO

    parametors:
      :address => DeliveryAddress[必須]

    return:
      引数として渡された、DelivaryAddressインスタンスが、会員登録住所でない場合、
      お届け先内容変更ポップアップを開くリンクを生成する。

    dependent:
      Customer#basic_address

=end
  def link_to_edit_address(address, custom_class = 'delivery_edit')
    address.frozen? and return nil
    link_to('変更', {:controller => :accounts, :action => :delivery_edit_popup, :id => address.id}, :class => custom_class)
  end

=begin rdoc
  * INFO

    parametors:
      :address => DeliveryAddress[必須]

    return:
      引数として渡された、DelivaryAddressインスタンスが、会員登録住所でない場合、
      追加お届け先を削除するリンクを生成する。

    dependent:
      Customer#basic_address

=end
  def link_to_delete_address(address, custom_class = nil)
    link_to('削除',
      {
        :controller => 'accounts',
        :action => 'delivery_destroy',
        :id => address.id,
        :backurl => url_for({:controller => 'cart', :action => 'shipping'})
      },
      {:confirm => "一度削除したデータは元には戻せません。\n削除してもよろしいですか？", :class => custom_class}
    ) unless address.frozen?
  end

  def link_to_continue_shopping
    if session[:cart_last_product_id]
      link_to 'お買い物を続ける', {:controller => 'product', :action => 'show', :id => session[:cart_last_product_id]}
    else
      link_to 'お買い物を続ける', {:controller => 'portal', :action => 'show'}
    end
  end
end
