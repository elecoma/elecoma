# -*- coding: utf-8 -*-
module PaymentPluginBase
  def complete
    return nil
  end

  def next_step(method_name)
    raise '遷移がありません'
  end

  def priv_step(method_name)
    raise '遷移がありません'
  end

  def cart_complete?(method_name)
    return false
  end

  def admin_controller
    raise '実装してください'
  end

  def user_setting_controller
    raise '実装してください'
  end

  def has_config?
    raise '実装してください'
  end
  
  # 管理画面の設定画面に飛ぶactionを返す
  def config
    # 例:
    # return :foobar_plugin_config
    raise '実装してください'
  end

  def has_data_management?
    raise '実装してください'
  end
  
  # 管理画面の設定画面に飛ぶactionを返す
  def data_management
    # 例:
    # return :foobar_plugin_data_management
    raise '実装してください'
  end

  def has_info?
    raise '実装してください'
  end

  def info
    raise '実装してください'
  end

  def before_order_delivery_destroy
    # 実装の際は返り値に有効無効かと、渡すメッセージを送ってください。
    # return true, nil
    # return false, "クレジット情報(xxxx)の取消処理をしてください"
    raise '実装してください'
  end

  def check_enable
    return true, ""
  end

  def payment_validate(payment)
    return true, ""
  end

  def order_has_datamanagement
    return false
  end

  # paramsを返す
  def get_datamanagement_by_order(order_code)
    raise "実装してください"
  end

  def user_navigation_list
    return Array.new
  end

end
