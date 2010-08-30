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

end
