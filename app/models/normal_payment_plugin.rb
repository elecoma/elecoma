# -*- coding: undecided -*-
class NormalPaymentPlugin < ActiveForm
  include PaymentPluginBase

  def complete
    return :before_finish
  end

  def next_step(method_name)
    return :before_finish if method_name == :complete
    super
  end

  def has_config?
    false
  end

  def payment_validate(payment)
    return false, "は共通の発送は選べません" if payment.common_delivery?
    return true, ""
  end


end
